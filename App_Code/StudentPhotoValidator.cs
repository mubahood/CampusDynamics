using System;
using System.Globalization;

/// <summary>
/// Decides whether an uploaded file is a photograph this system can actually store,
/// and when it is not, says why in words a student or a clerk can act on.
///
/// SHARED ON PURPOSE. Both upload paths use this — the student's self-service
/// handler (SelfPhotoUpload.ashx) and the administrator's uploader on
/// PhotoChangeController.aspx. Two copies of security-critical validation drift
/// apart; the weaker copy then becomes the way in. There is one implementation.
///
/// The file is judged by its CONTENT, never by its name. Judging by extension was
/// wrong in both directions: it turned away photographs GDI+ reads perfectly well
/// (a camera file with no extension, the .jfif Windows sometimes writes), and it
/// waved through anything at all that had been named .jpg — a PDF renamed
/// photo.jpg sailed past and then failed deep inside GDI+ as a generic error.
/// </summary>
public static class StudentPhotoValidator
{
    /// <summary>
    /// Biggest upload accepted. The stored photograph is a 300x400 thumbnail whatever
    /// arrives, so this is a memory guard rather than a quality rule — an ordinary
    /// phone photograph is 3-8 MB and was once refused at 2 MB for nobody's benefit.
    /// web.config allows 50 MB at the transport layer, so this is the real limit.
    /// </summary>
    public const int MaxUploadBytes = 5 * 1024 * 1024;

    /// <summary>
    /// A file's SIZE says nothing about the memory decoding it needs: a few MB of JPEG
    /// can encode hundreds of megapixels of flat colour, and decoding that would take
    /// the app pool down. Real photographs are far below this.
    /// </summary>
    public const long MaxSourcePixels = 60000000L;   // 60 megapixels

    /// <summary>Faces at 300x400 get printed on ID cards; 90 is worth the ~2 KB over GDI+'s default 75.</summary>
    public const long ThumbJpegQuality = 90L;

    public enum PicKind { Unknown, Jpeg, Png, Gif, Bmp, Tiff, Heic, Avif, Webp }

    /// <summary>
    /// True when GDI+ will be able to open this file and it is safe to decode.
    /// On false, <paramref name="why"/> names the actual problem and what to do about it.
    /// </summary>
    public static bool IsUsablePhoto(byte[] bytes, out string why)
    {
        why = "";

        if (bytes == null || bytes.Length == 0)
        {
            why = "No file was received. Please choose a photograph and try again.";
            return false;
        }
        if (bytes.Length > MaxUploadBytes)
        {
            why = "This photo is " + SizeLabel(bytes.Length) + ", and the biggest we can take is "
                + SizeLabel(MaxUploadBytes) + ". Please use a smaller copy of the photo.";
            return false;
        }

        PicKind kind = Sniff(bytes);
        switch (kind)
        {
            case PicKind.Heic:
                // Windows Server 2019 ships no HEIF codec, so GDI+ cannot open these at all.
                why = "This photo is saved in the HEIC format, which our system cannot open. "
                    + "iPhones save photos this way. On the iPhone go to Settings, then Camera, then Formats, "
                    + "and choose \"Most Compatible\". Take the photo again and send it. "
                    + "Any photo studio can also give you a JPG copy.";
                return false;

            case PicKind.Avif:
                why = "This photo is saved in the AVIF format, which our system cannot open. "
                    + "Some newer Android phones save photos this way. In the camera settings, "
                    + "look for the photo format and choose JPG, then take the photo again. "
                    + "Any photo studio can also give you a JPG copy.";
                return false;

            case PicKind.Webp:
                why = "This picture is in the WEBP format, which our system cannot open. "
                    + "This usually happens when a picture is saved from a website. "
                    + "Please use a real photograph saved as JPG.";
                return false;

            case PicKind.Unknown:
                why = "This file is not a photograph. Please choose a picture file (JPG or PNG).";
                return false;
        }

        int w, h;
        if (TryReadSize(bytes, kind, out w, out h) && w > 0 && h > 0)
        {
            if ((long)w * (long)h > MaxSourcePixels)
            {
                why = "This picture is " + w + " by " + h + " and is too big for our system to open. "
                    + "Please use a normal photograph taken with a phone or camera.";
                return false;
            }
        }

        return true;
    }

    /// <summary>Identifies the format from its leading bytes (the "magic number").</summary>
    public static PicKind Sniff(byte[] b)
    {
        if (b == null || b.Length < 12) return PicKind.Unknown;

        if (b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) return PicKind.Jpeg;

        if (b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47 &&
            b[4] == 0x0D && b[5] == 0x0A && b[6] == 0x1A && b[7] == 0x0A) return PicKind.Png;

        if (b[0] == 'G' && b[1] == 'I' && b[2] == 'F' && b[3] == '8') return PicKind.Gif;

        if (b[0] == 'B' && b[1] == 'M') return PicKind.Bmp;

        if ((b[0] == 0x49 && b[1] == 0x49 && b[2] == 0x2A && b[3] == 0x00) ||
            (b[0] == 0x4D && b[1] == 0x4D && b[2] == 0x00 && b[3] == 0x2A)) return PicKind.Tiff;

        if (b[0] == 'R' && b[1] == 'I' && b[2] == 'F' && b[3] == 'F' &&
            b[8] == 'W' && b[9] == 'E' && b[10] == 'B' && b[11] == 'P') return PicKind.Webp;

        // ISO base media container: [size:4]["ftyp"][brand:4]. Covers HEIC/HEIF from
        // iPhones and AVIF from newer Android phones — none of which GDI+ can read.
        if (b[4] == 'f' && b[5] == 't' && b[6] == 'y' && b[7] == 'p')
        {
            string brand = new string(new char[] { (char)b[8], (char)b[9], (char)b[10], (char)b[11] }).ToLowerInvariant();
            switch (brand)
            {
                case "heic": case "heix": case "heim": case "heis":
                case "hevc": case "hevx": case "mif1": case "msf1":
                    return PicKind.Heic;
                case "avif": case "avis":
                    return PicKind.Avif;
            }
        }

        return PicKind.Unknown;
    }

    /// <summary>
    /// Reads the pixel dimensions straight out of the file header, WITHOUT decoding.
    /// This has to happen before GDI+ touches the file: Image.FromStream allocates the
    /// full decoded bitmap, so by the time a Width property could be read the memory has
    /// already been taken. Returns false for formats not worth parsing.
    /// </summary>
    public static bool TryReadSize(byte[] b, PicKind kind, out int w, out int h)
    {
        w = 0; h = 0;
        try
        {
            switch (kind)
            {
                case PicKind.Png:
                    // IHDR is always the first chunk: width and height are big-endian at 16 and 20.
                    if (b.Length < 24) return false;
                    w = BE32(b, 16); h = BE32(b, 20);
                    return true;

                case PicKind.Gif:
                    if (b.Length < 10) return false;
                    w = b[6] | (b[7] << 8); h = b[8] | (b[9] << 8);
                    return true;

                case PicKind.Bmp:
                    if (b.Length < 26) return false;
                    w = LE32(b, 18); h = Math.Abs(LE32(b, 22));   // height is negative for top-down bitmaps
                    return true;

                case PicKind.Jpeg:
                    return TryReadJpegSize(b, out w, out h);
            }
        }
        catch { /* malformed header — let GDI+ be the judge */ }
        return false;
    }

    /// <summary>
    /// Walks the JPEG marker segments to the start-of-frame, which carries the real
    /// dimensions. Everything before it (EXIF, embedded thumbnails, colour profiles) is
    /// skipped by its declared length.
    /// </summary>
    private static bool TryReadJpegSize(byte[] b, out int w, out int h)
    {
        w = 0; h = 0;
        int i = 2;                                    // past SOI (FF D8)
        while (i + 3 < b.Length)
        {
            if (b[i] != 0xFF) { i++; continue; }       // resynchronise on padding
            int marker = b[i + 1];
            if (marker == 0xFF) { i++; continue; }     // fill byte
            if (marker == 0xD8 || marker == 0x01 || (marker >= 0xD0 && marker <= 0xD7)) { i += 2; continue; }
            if (marker == 0xD9 || marker == 0xDA) return false;   // end of image / start of scan

            int segLen = (b[i + 2] << 8) | b[i + 3];
            if (segLen < 2) return false;

            // SOF0-SOF15 carry the frame size. C4 = Huffman tables, C8 = extension,
            // CC = arithmetic coding tables — those share the range but are not frames.
            bool isFrame = marker >= 0xC0 && marker <= 0xCF
                           && marker != 0xC4 && marker != 0xC8 && marker != 0xCC;
            if (isFrame)
            {
                if (i + 9 >= b.Length) return false;
                h = (b[i + 5] << 8) | b[i + 6];
                w = (b[i + 7] << 8) | b[i + 8];
                return true;
            }
            i += 2 + segLen;
        }
        return false;
    }

    private static int BE32(byte[] b, int o) { return (b[o] << 24) | (b[o + 1] << 16) | (b[o + 2] << 8) | b[o + 3]; }
    private static int LE32(byte[] b, int o) { return b[o] | (b[o + 1] << 8) | (b[o + 2] << 16) | (b[o + 3] << 24); }

    /// <summary>Human-readable byte size, for messages that quote the real numbers back.</summary>
    public static string SizeLabel(long bytes)
    {
        if (bytes >= 1048576) return (bytes / 1048576.0).ToString("0.#", CultureInfo.InvariantCulture) + " MB";
        return Math.Max(1, (int)Math.Round(bytes / 1024.0)).ToString(CultureInfo.InvariantCulture) + " KB";
    }
}
