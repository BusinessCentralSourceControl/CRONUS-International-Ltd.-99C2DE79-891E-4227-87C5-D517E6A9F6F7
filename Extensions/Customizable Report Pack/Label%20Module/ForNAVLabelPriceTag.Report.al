dotnet // --> Reports ForNAV Autogenerated code - do not delete or modify
{	
	assembly("ForNav.Reports.6.0.0.2078")
	{
		type(ForNav.Report_6_0_0_2078; ForNavReport6188669_v6_0_0_2078){}   
	}
} // Reports ForNAV Autogenerated code - do not delete or modify -->

Report 6188669 "ForNAV Label Price Tag"
{
	RDLCLayout = './Layouts/ForNAV Label Price Tag.rdlc'; DefaultLayout = RDLC;

	dataset
	{
		dataitem(Label;"ForNAV Label")
		{
			UseTemporary = true;
			column(ReportForNavId_1; 1) {} // Autogenerated by ForNav - Do not delete
			trigger OnPreDataItem();
			begin
			end;
			
		}
	}


	requestpage
	{


		SaveValues = false;		layout
		{
			area(content)
			{
				group(Options)
				{
					Caption = 'Options';
					field(ForNavOpenDesigner; ReportForNavOpenDesigner)
					{
						ApplicationArea = All;
						Caption = 'Design';
						Visible = ReportForNavAllowDesign;
						trigger OnValidate()
						begin
							ReportForNav.LaunchDesigner(ReportForNavOpenDesigner);
							CurrReport.RequestOptionsPage.Close();
						end;
					}
				}
			}
		}

		actions
		{
		}
		trigger OnOpenPage()
		begin
			ReportForNavOpenDesigner := false;
		end;
	}

	trigger OnInitReport()
	begin
		GetData;
		;ReportsForNavInit;
		Codeunit.Run(Codeunit::"ForNAV First Time Setup");
	end;

	trigger OnPostReport()
	begin

		;ReportForNav.Post;

	end;

	trigger OnPreReport()
	var
		InStr: InStream;
	begin
		if TempBlob.FindFirst then begin
			TempBlob.CalcFields(Blob);
			TempBlob.Blob.CreateInstream(InStr);
			ReportForNav.GetDataItem('Label').AppendPdf( InStr);
			TempBlob.Delete;
		end;
		;

		;ReportsForNavPre;

	end;
	var
		TempBlob: Record "ForNAV Core Setup" temporary;

	local procedure GetData()
	var
		LabelMgt: Codeunit "ForNAV Label Mgt.";
	begin
		LabelMgt.GetData(Label);
		LabelMgt.GetMergePDF(TempBlob);
		ReportForNavOpenDesigner := Label."ForNAV Design";
	end;

	procedure SetMergePDF(var TempBlobIn: Record "ForNAV Core Setup")
	begin
		TempBlob.Copy(TempBlobIn, true);
	end;

	// --> Reports ForNAV Autogenerated code - do not delete or modify
	var 
		[WithEvents]
		ReportForNav : DotNet ForNavReport6188669_v6_0_0_2078;
		ReportForNavOpenDesigner : Boolean;
		[InDataSet]
		ReportForNavAllowDesign : Boolean;

	local procedure ReportsForNavInit();
	var
		addInFileName : Text;
		tempAddInFileName : Text;
		path: DotNet Path;
		ApplicationSystemConstants: Codeunit "Application System Constants";
	begin
		addInFileName := ApplicationPath() + 'Add-ins\ReportsForNAV_6_0_0_2078\ForNav.Reports.6.0.0.2078.dll';
		if not File.Exists(addInFileName) then begin
			tempAddInFileName := path.GetTempPath() + '\Microsoft Dynamics NAV\Add-Ins\' + ApplicationSystemConstants.PlatformFileVersion() + '\ForNav.Reports.6.0.0.2078.dll';
			if not File.Exists(tempAddInFileName) then
				Error('Please install the ForNAV DLL version 6.0.0.2078 in your service tier Add-ins folder under the file name "%1"\\If you already have the ForNAV DLL on the server, you should move it to this folder and rename it to match this file name.', addInFileName);
		end;
		ReportForNav:= ReportForNav.Report_6_0_0_2078(CurrReport.ObjectId(), CurrReport.Language(), SerialNumber(), UserId(), CompanyName());
		ReportForNav.Init();
	end;

	local procedure ReportsForNavPre();
	begin
		ReportForNav.OpenDesigner:=ReportForNavOpenDesigner;
		if not ReportForNav.Pre() then CurrReport.Quit();
	end;

	// Reports ForNAV Autogenerated code - do not delete or modify -->
}
