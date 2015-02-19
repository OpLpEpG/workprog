unit Tst_D2D1;

interface

uses  Winapi.d2d1,  Vcl.ExtCtrls, Vcl.Direct2D, Winapi.DxgiFormat,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TForm2 = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
      factory : ID2D1Factory;
      renderTarget : ID2D1HwndRenderTarget;
      bmp: ID2D1Bitmap;
      b1,b2 : ID2D1SolidColorBrush;
      b: TBitmap;
      procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

function D2D1InfiniteRect() : TD2D1RectF;
begin
    result.top := - MINSHORT;
    result.left := - MINSHORT;
    result.right :=   MAXSHORT;
    result.bottom :=   MAXSHORT;
end;

function CreateBitmap(rnd: ID2D1RenderTarget; Bitmap: TBitmap): ID2D1Bitmap;
var
  BitmapInfo: TBitmapInfo;
  buf: array of Byte;
  BitmapProperties: TD2D1BitmapProperties;
  Hbmp: HBitmap;
begin
  FillChar(BitmapInfo, SizeOf(BitmapInfo), 0);
  BitmapInfo.bmiHeader.biSize := Sizeof(BitmapInfo.bmiHeader);
  BitmapInfo.bmiHeader.biHeight := -Bitmap.Height;
  BitmapInfo.bmiHeader.biWidth := Bitmap.Width;
  BitmapInfo.bmiHeader.biPlanes := 1;
  BitmapInfo.bmiHeader.biBitCount := 32;

  SetLength(buf, Bitmap.Height * Bitmap.Width * 4);
  // Forces evaluation of Bitmap.Handle before Bitmap.Canvas.Handle
  Hbmp := Bitmap.Handle;
  GetDIBits(Bitmap.Canvas.Handle, Hbmp, 0, Bitmap.Height, @buf[0], BitmapInfo, DIB_RGB_COLORS);

  BitmapProperties.dpiX := 0;
  BitmapProperties.dpiY := 0;
  BitmapProperties.pixelFormat.format := DXGI_FORMAT_B8G8R8A8_UNORM;
  if (Bitmap.PixelFormat <> pf32bit) or (Bitmap.AlphaFormat = afIgnored) then
    BitmapProperties.pixelFormat.alphaMode := D2D1_ALPHA_MODE_IGNORE
  else
    BitmapProperties.pixelFormat.alphaMode := D2D1_ALPHA_MODE_PREMULTIPLIED;

  rnd.CreateBitmap(D2D1SizeU(Bitmap.Width, Bitmap.Height), @buf[0], 4*Bitmap.Width, BitmapProperties, Result)
end;


procedure TForm2.FormCreate(Sender: TObject);
 var
  size : TD2D1SizeU;
begin
  D2D1CreateFactory(D2D1_FACTORY_TYPE_SINGLE_THREADED,  IID_ID2D1Factory, nil, factory);

    size := D2D1SizeU(self.ClientWidth, self.ClientHeight);

    factory.CreateHwndRenderTarget( D2D1RenderTargetProperties(),
                                   D2D1HwndRenderTargetProperties(handle, size),
                                   renderTarget
                                  );

    renderTarget.CreateSolidColorBrush( D2D1ColorF(0.7, 0.7, 0.75, 1), nil, b1);
    renderTarget.CreateSolidColorBrush( D2D1ColorF(0.5, 0.5, 0.55, 1), nil, b2);

//    img := TImage.Create(self);
//    img.Picture.LoadFromFile('c:\Program Files\Atmel\AVR Studio 5.1\AVR Qtouch Studio\Splash.bmp');

    b :=  TBitmap.Create;

    b.LoadFromFile('c:\Program Files\Atmel\AVR Studio 5.1\AVR Qtouch Studio\Splash.bmp');

    bmp := CreateBitmap(renderTarget, b);

end;

procedure TForm2.FormPaint(Sender: TObject);
  var
    size : D2D1_SIZE_F;
    w,h : integer;
    x,y : integer;
    r1,r2 : TD2DRectF;
    layer : ID2D1Layer;
    lp : TD2D1LayerParameters;

    gc : ID2D1GradientStopCollection;
    gs : array[0..1] of TD2D1GradientStop;
    gb : ID2D1RadialGradientBrush;

begin

    renderTarget.BeginDraw;
    renderTarget.SetTransform(TD2DMatrix3x2F.Identity);
    renderTarget.Clear(D2D1ColorF(1,1,1,1));
    renderTarget.GetSize(size);

    w := round(size.width);
    h := round(size.height);

    x :=0;
    while x  < w do begin
        renderTarget.DrawLine(D2D1PointF(x,0),D2D1PointF(x,h),b1,0.5);
        inc(x,10);
    end;
    y :=0 ;
    while y < h do begin
        renderTarget.DrawLine(D2D1PointF(0,y),D2D1PointF(w,y),b1,0.5);
        inc(y,10);
    end;

   { r1 := D2D1RectF(w div 2 - 50,
                    h div 2 - 50,
                    w div 2 + 50,
                    h div 2 + 50 );

    r2 := D2D1RectF(w div 2 - 100,
                    h div 2 - 100,
                    w div 2 + 100,
                    h div 2 + 100 );

    renderTarget.FillRectangle(r1,b1);
    renderTarget.DrawRectangle(r2,b2);}


        renderTarget.SetTransform(TD2DMatrix3x2F.Translation(300, 100));
        renderTarget.CreateLayer(nil,layer);

//        zeroMemory(@lp,sizeof(lp));
//        lp.contentBounds := D2D1RectF(50,50,150,200);
//        lp.opacity := 0.45;



        renderTarget.SetTransform(TD2DMatrix3x2F.Translation(450,20 ));

        zeroMemory(@lp,sizeof(lp));
        lp.contentBounds := D2D1InfiniteRect();
        lp.maskAntialiasMode := D2D1_ANTIALIAS_MODE_PER_PRIMITIVE;
        lp.maskTransform := TD2DMatrix3x2F.Identity();
        lp.opacity := 1;
        gs[0].position := 0;
        gs[0].color :=  D2D1ColorF(clWhite,1);
        gs[1].position := 1;
        gs[1].color := D2D1ColorF(clWhite,0);
        renderTarget.CreateGradientStopCollection(@gs,2,D2D1_GAMMA_2_2,D2D1_EXTEND_MODE_CLAMP,gc);

        renderTarget.CreateRadialGradientBrush(
                         D2D1RadialGradientBrushProperties(D2D1PointF(90,210),D2D1PointF(0,0),90,90),
                         nil,
                         gc,
                         gb
                     );
        lp.opacityBrush := gb;
        //canvas.CreateBrush([clBlack,clWhite],D2D1PointF(50,50),D2D1PointF(0,0),50,50);
        lp.layerOptions := D2D1_LAYER_OPTIONS_NONE;




        renderTarget.PushLayer(lp,layer);


        renderTarget.DrawBitmap(bmp);

        renderTarget.PopLayer();


    renderTarget.EndDraw();
end;

procedure TForm2.FormResize(Sender: TObject);
  var
    size : D2D1_SIZE_u;
begin
    size := D2D1SizeU(ClientWidth,ClientHeight);
    renderTarget.Resize(size);
    self.Invalidate;
end;

procedure TForm2.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  message.result := 1;
end;

end.
