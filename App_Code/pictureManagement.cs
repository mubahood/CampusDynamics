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
        int newwidth = widthThumb;
        int newheight = heightThumb;

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
