unit AdMob;

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.StdCtrls,
  FMX.Forms, FMX.Layouts,
  DPF.iOS.Common
{$IFDEF iOS}
    , FMX.Media.iOS, FMX.Media, iOSapi.AVFoundation, iOSapi.Foundation,
  System.Types, Posix.Dlfcn, Macapi.ObjectiveC, Macapi.ObjCRuntime,
  FMX.Platform.iOS, iOSapi.CocoaTypes, iOSapi.uikit, iOSapi.CoreGraphics,
  DPF.iOS.MFMailComposeViewController, DPF.iOS.StoreKit, DPF.iOS.SCNetworks

  {$ENDIF}
    ;

{$IFDEF iOS}

type
  AdMobLibrary = interface(NSObject)
    ['{AAF116B8-58D7-4A28-B755-ADDA11442E09}']
    procedure setAdMob_id(AdMob_Id: NSString); cdecl;
    function getBannerView(GADAdSize: integer): UIView; cdecl;
  end;

  AdMobLibraryClass = interface(NSObjectClass)
    ['{689B04E2-F080-437F-8F49-26CE0AD2730F}']
  end;

  TAdMobLibraryClass = class(TOCGenericImport<AdMobLibraryClass, AdMobLibrary>)
  end;
{$ENDIF}

const
  kGADAdSizeBanner = 1;
  kGADAdSizeMediumRectangle = 2;
  kGADAdSizeFullBanner = 3;
  kGADAdSizeLeaderboard = 4;
  kGADAdSizeSkyscraper = 5;
  kGADAdSizeSmartBannerPortrait = 6;
  kGADAdSizeSmartBannerLandscape = 7;
  kGADAdSizeInvalid = 8;

type

  [ComponentPlatformsAttribute(pidiOSDevice { or pidAndroid } )]
  TAdMob = class(TLayout)
  private
    { Private declarations }
{$IFDEF iOS}
    FAdMob: AdMobLibrary;
{$ENDIF}
    FAdMobSize: integer;
    FAdMObId: String;
    procedure SetAdMObId(const Value: String);
    function GetAdMobSize: integer;
  protected
    { Protected declarations }
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property AdMobSize: integer read GetAdMobSize write FAdMobSize;
    property AdMobID: String read FAdMObId write SetAdMObId;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('AdMob', [TAdMob]);
end;

{$IFDEF iOS}
{$O-}
function fakeLoader(I: integer): integer; cdecl;
  external 'libAdMobLibrary.a' name 'fakeLoader';

function _NSStringFromGADAdSize: NSString; cdecl;
  external 'libGoogleAdMobAds.a' name 'NSStringFromGADAdSize';

procedure fakeAdSupport; cdecl;
  external '/System/Library/Frameworks/AdSupport.framework/AdSupport' name
  'OBJC_CLASS_$_ASIdentifierManager';

{$O+}
{$ENDIF}
{ TAdMob }

constructor TAdMob.Create(AOwner: TComponent);
begin
  inherited;

{$IFDEF iOS}
  //fakeLoader(1);
  FAdMob := TAdMobLibraryClass.Create;
  FAdMob.init;
  if FAdMobSize = 0 then
  begin
    if IsIPad then
      FAdMobSize := kGADAdSizeLeaderboard
    else
      FAdMobSize := kGADAdSizeBanner;
  end;

{$ENDIF}
end;

destructor TAdMob.Destroy;
begin

  inherited;
end;

function TAdMob.GetAdMobSize: integer;
begin
  if FAdMobSize = 0 then
  begin
    if IsIPad then
      result := kGADAdSizeLeaderboard
    else
      result := kGADAdSizeBanner;
  end
  else
    result := FAdMobSize;
end;

procedure TAdMob.Paint;
{$IFDEF iOS}
var
  banner: UIView;
{$ENDIF}
begin
  inherited;
{$IFDEF iOS}
  if Assigned(Owner) and Assigned(TCommonCustomForm(Owner).Handle) then
  begin
    banner := FAdMob.getBannerView(Ord(FAdMobSize));
    WindowHandleToPlatform(TCommonCustomForm(Owner).Handle)
      .View.addSubview(banner)
  end;
{$ENDIF}
end;

procedure TAdMob.SetAdMObId(const Value: String);
begin
  FAdMObId := Value;
{$IFDEF iOS}
  FAdMob.setAdMob_id(NSSTR(Value));
{$ENDIF}
end;

end.
