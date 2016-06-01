//
// https://github.com/showcode
//

library applet;

uses
  CtlPanel,
  maincpl in 'maincpl.pas' {amServerCpl: TAppletModule},
  appconst in '..\common\appconst.pas';

exports CPlApplet;

{$R *.RES}

{$E cpl}

begin
  Application.Initialize;
  Application.CreateForm(TamServerCpl, amServerCpl);
  Application.Run;
end.