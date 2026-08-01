using System;
using System.Collections.Generic;
using System.Web;
using System.IO;
using System.Drawing;

/// <summary>
/// Summary description for pictureManagement
/// </summary>
public class imageManager
{
    const int widthThumb = 300;
    const int heightThumb = 400;
    const int signWidth = 200;
    const int signHeight = 100;

    public byte[] MakeThumb(byte[] fullsize)
    {
        return ResizeCover(fullsize, widthThumb, heightThumb);
    }

    /// <summary>
    /// Produces a targetW x targetH JPEG that PRESERVES the aspect ratio: the source is
    /// centre-cropped to the exact target ratio, then scaled — so faces are never stretched.
    /// Also honours EXIF orientation (fixes sideways phone photos) and uses high-quality
    /// resampling.
    /// </summary>
    private static byte[] ResizeCover(byte[] fullsize, int targetW, int targetH)
    {
        using (Image iOriginal = Image.FromStream(new MemoryStream(fullsize)))
        {
            ApplyExifOrientation(iOriginal);

            double targetAspect = (double)targetW / targetH;
            double srcAspect = (double)iOriginal.Width / iOriginal.Height;

            int cropW, cropH;
            if (srcAspect > targetAspect)
            {
                // Source is wider than the target ratio -> trim the left & right.
                cropH = iOriginal.Height;
                cropW = (int)Math.Round(cropH * targetAspect);
            }
            else
            {
                // Source is taller than the target ratio -> trim the top & bottom.
                cropW = iOriginal.Width;
                cropH = (int)Math.Round(cropW / targetAspect);
            }
            if (cropW < 1) cropW = iOriginal.Width;
            if (cropH < 1) cropH = iOriginal.Height;

            Rectangle srcRect = new Rectangle(
                (iOriginal.Width - cropW) / 2,
                (iOriginal.Height - cropH) / 2,
                cropW, cropH);

            using (Bitmap iThumb = new Bitmap(targetW, targetH))
            {
                using (Graphics g = Graphics.FromImage(iThumb))
                {
                    g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
                    g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
                    g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.HighQuality;
                    g.CompositingQuality = System.Drawing.Drawing2D.CompositingQuality.HighQuality;
                    g.DrawImage(iOriginal, new Rectangle(0, 0, targetW, targetH), srcRect, GraphicsUnit.Pixel);
                }
                using (MemoryStream m = new MemoryStream())
                {
                    iThumb.Save(m, System.Drawing.Imaging.ImageFormat.Jpeg);
                    return m.ToArray();
                }
            }
        }
    }

    /// <summary>Rotates/flips the image per its EXIF orientation tag, then clears the tag.</summary>
    private static void ApplyExifOrientation(Image img)
    {
        const int ExifOrientationId = 0x0112;
        try
        {
            if (Array.IndexOf(img.PropertyIdList, ExifOrientationId) < 0) return;
            var prop = img.GetPropertyItem(ExifOrientationId);
            int val = BitConverter.ToUInt16(prop.Value, 0);
            System.Drawing.RotateFlipType rot = System.Drawing.RotateFlipType.RotateNoneFlipNone;
            switch (val)
            {
                case 2: rot = System.Drawing.RotateFlipType.RotateNoneFlipX; break;
                case 3: rot = System.Drawing.RotateFlipType.Rotate180FlipNone; break;
                case 4: rot = System.Drawing.RotateFlipType.Rotate180FlipX; break;
                case 5: rot = System.Drawing.RotateFlipType.Rotate90FlipX; break;
                case 6: rot = System.Drawing.RotateFlipType.Rotate90FlipNone; break;
                case 7: rot = System.Drawing.RotateFlipType.Rotate270FlipX; break;
                case 8: rot = System.Drawing.RotateFlipType.Rotate270FlipNone; break;
            }
            if (rot != System.Drawing.RotateFlipType.RotateNoneFlipNone)
            {
                img.RotateFlip(rot);
                img.RemovePropertyItem(ExifOrientationId);
            }
        }
        catch { /* no/invalid EXIF — leave as-is */ }
    }

    public byte[] MakeSignatureThumb(byte[] fullsize)
    {
        int newwidth = signWidth;
        int newheight = signHeight;

        Image iOriginal, iThumb;
        double scaleH, scaleW;

        Rectangle srcRect = new Rectangle();
        iOriginal = Image.FromStream(new MemoryStream(fullsize));
        scaleH = iOriginal.Height / newheight;
        scaleW = iOriginal.Width / newwidth;
        if (scaleH == scaleW)
        {
            srcRect.Width = iOriginal.Width;
            srcRect.Height = iOriginal.Height;
            srcRect.X = 0;
            srcRect.Y = 0;
        }
        else if ((scaleH) > (scaleW))
        {
            srcRect.Width = iOriginal.Width;
            srcRect.Height = Convert.ToInt32(newheight * scaleW);
            srcRect.X = 0;
            srcRect.Y = Convert.ToInt32((iOriginal.Height - srcRect.Height) / 2);
        }
        else
        {
            srcRect.Width = Convert.ToInt32(newwidth * scaleH);
            srcRect.Height = iOriginal.Height;
            srcRect.X = Convert.ToInt32((iOriginal.Width - srcRect.Width) / 2);
            srcRect.Y = 0;
        }
        iThumb = new Bitmap(newwidth, newheight);
        Graphics g = Graphics.FromImage(iThumb);
        g.DrawImage(iOriginal, new Rectangle(0, 0, newwidth, newheight), srcRect, GraphicsUnit.Pixel);
        MemoryStream m = new MemoryStream();
        iThumb.Save(m, System.Drawing.Imaging.ImageFormat.Bmp);
        return m.GetBuffer();
    }
}
