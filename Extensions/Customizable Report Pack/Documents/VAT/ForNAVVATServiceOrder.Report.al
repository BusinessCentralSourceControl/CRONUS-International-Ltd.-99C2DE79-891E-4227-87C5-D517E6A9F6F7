dotnet // --> Reports ForNAV Autogenerated code - do not delete or modify
{	
	assembly("ForNav.Reports.6.0.0.2078")
	{
		type(ForNav.Report_6_0_0_2078; ForNavReport6188476_v6_0_0_2078){}   
	}
} // Reports ForNAV Autogenerated code - do not delete or modify -->

Report 6188476 "ForNAV VAT Service Order"
{
	Caption = 'Service Order';
	UsageCategory = ReportsAndAnalysis;
	RDLCLayout = './Layouts/ForNAV VAT Service Order.rdlc'; DefaultLayout = RDLC;

	dataset
	{
		dataitem(Header;"Service Header")
		{
			DataItemTableView = sorting("No.") where("Document Type" = const(Order));
			MaxIteration = 1;
			RequestFilterFields = "No.", "Posting Date";
			column(ReportForNavId_2; 2) {} // Autogenerated by ForNav - Do not delete
			column(HasDiscount; ForNAVCheckDocumentDiscount.HasDiscount(Header))
			{
				IncludeCaption = false;
			}
			column(SingleVATPct; VATAmountLine.ForNavSingleVATPct())
			{
				IncludeCaption = false;
			}
			dataitem(ItemLine;"Service Item Line")
			{
				DataItemLinkReference = Header;
				DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
				DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
				column(ReportForNavId_1; 1) {} // Autogenerated by ForNav - Do not delete
				dataitem(ServiceCommentLine;"Service Comment Line")
				{
					DataItemLink = "Table Subtype" = FIELD("Document Type"), "No." = FIELD("Document No."), "Table Line No." = FIELD("Line No.");
					DataItemTableView = sorting("Table Name", "Table Subtype", "No.", Type, "Table Line No.", "Line No.") where("Table Name" = const("Service Header"), Type = filter(Fault | Resolution));
					column(ReportForNavId_1000000003; 1000000003) {} // Autogenerated by ForNav - Do not delete
					trigger OnPreDataItem();
					begin
					end;
					
				}
				trigger OnPreDataItem();
				begin
				end;
				
			}
			dataitem(Line;"Service Line")
			{
				DataItemLinkReference = Header;
				DataItemLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
				DataItemTableView = sorting("Document Type", "Document No.", "Line No.");
				column(ReportForNavId_3; 3) {} // Autogenerated by ForNav - Do not delete
				trigger OnPreDataItem();
				begin
				end;
				
			}
			dataitem(VATAmountLine;"VAT Amount Line")
			{
				UseTemporary = true;
				DataItemTableView = sorting("VAT Identifier", "VAT Calculation Type", "Tax Group Code", "Use Tax", Positive);
				column(ReportForNavId_1000000001; 1000000001) {} // Autogenerated by ForNav - Do not delete
				trigger OnPreDataItem();
				begin
					if not PrintVATAmountLines then
						CurrReport.Break;
				end;
				
			}
			dataitem(VATClause;"VAT Clause")
			{
				UseTemporary = true;
				DataItemTableView = sorting(Code);
				column(ReportForNavId_1000000002; 1000000002) {} // Autogenerated by ForNav - Do not delete
				trigger OnPreDataItem();
				begin
				end;
				
			}
			trigger OnPreDataItem();
			begin
			end;
			
			trigger OnAfterGetRecord();
			begin
			
				ChangeLanguage("Language Code");
				GetVatAmountLines;
				GetVATClauses;
			end;
			
		}
	}


	requestpage
	{

		SaveValues = true;

		layout
		{
			area(content)
			{
				group(Options)
				{
					Caption = 'Options';
					field(NoOfCopies; NoOfCopies)
					{
						ApplicationArea = All;
						Caption = 'No. of Copies';
					}
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
		;ReportsForNavInit;
		Codeunit.Run(Codeunit::"ForNAV First Time Setup");
		Commit;
		ReportForNavOpenDesigner := ReportForNavAllowDesign;
	end;

	trigger OnPostReport()
	begin


		;ReportForNav.Post;

	end;

	trigger OnPreReport()
	var
		ForNAVSetup: Record "ForNAV Setup";
	begin
		;

		ReportForNav.GetDataItem('Header').Copies( NoOfCopies);
		LoadWatermark;
		;ReportsForNavPre;

	end;
	var
		ForNAVCheckDocumentDiscount: Codeunit "ForNAV Check Document Discount";
		NoOfCopies: Integer;

	local procedure ChangeLanguage(LanguageCode: Code[10])
	var
		ForNAVSetup: Record "ForNAV Setup";
	begin
		ForNAVSetup.Get;
		if ForNAVSetup."Inherit Language Code" then
			CurrReport.Language(ReportForNav.GetLanguageID(LanguageCode));
	end;

	local procedure GetVatAmountLines()
	var
		ForNAVGetVatAmountLines: Codeunit "ForNAV Get Vat Amount Lines";
	begin
		VATAmountLine.DeleteAll;
		ForNAVGetVatAmountLines.GetVatAmountLines(Header, VATAmountLine);
	end;

	local procedure GetVATClauses()
	var
		ForNAVGetVatClause: Codeunit "ForNAV Get Vat Clause";
	begin
		VATClause.DeleteAll;
		ForNAVGetVatClause.GetVATClauses(VATAmountLine, VATClause, Header."Language Code");
	end;

	local procedure PrintVATAmountLines(): Boolean
	var
		ForNAVSetup: Record "ForNAV Setup";
	begin
		ForNAVSetup.Get;
		case ForNAVSetup."VAT Report Type" of
			ForNAVSetup."vat report type"::Always:
				exit(true);
			ForNAVSetup."vat report type"::"Multiple Lines":
				exit(VATAmountLine.Count > 1);
			ForNAVSetup."vat report type"::Never:
				exit(false);
		end;

	end;

	local procedure LoadWatermark()
	var
		ForNAVSetup: Record "ForNAV Setup";
		OutStream: OutStream;
	begin
		ForNAVSetup.Get;
		if not PrintLogo(ForNAVSetup) then
			exit;
		ForNAVSetup.CalcFields(ForNAVSetup."Document Watermark");
		if not ForNAVSetup."Document Watermark".Hasvalue then
			exit;

		ForNavSetup."Document Watermark".CreateOutstream(OutStream); ReportForNav.Watermark.Image.Load(OutStream);

	end;

	procedure PrintLogo(ForNAVSetup: Record "ForNAV Setup"): Boolean
	begin
		if not ForNAVSetup."Use Preprinted Paper" then
			exit(true);
		if ReportForNav.PrinterSettings.PrintTo = 'PDF' then
			exit(true);
		if ReportForNav.PrinterSettings.PrintTo = 'Preview' then
			exit(true);
		exit(false);
	end;

	// --> Reports ForNAV Autogenerated code - do not delete or modify
	var 
		[WithEvents]
		ReportForNav : DotNet ForNavReport6188476_v6_0_0_2078;
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
