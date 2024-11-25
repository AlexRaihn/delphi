unit ProductUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Data.DB, 
  Vcl.DBCtrls, DatabaseUnit;

type
  TProductMode = (pmAdd, pmEdit);

  TProductForm = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    edtName: TEdit;
    edtQuantity: TEdit;
    edtPrice: TEdit;
    edtMinQuantity: TEdit;
    edtBarcode: TEdit;
    edtLocation: TEdit;
    memDescription: TMemo;
    cmbCategory: TDBLookupComboBox;
    cmbSupplier: TDBLookupComboBox;
    btnSave: TButton;
    btnCancel: TButton;
    dsCategories: TDataSource;
    dsSuppliers: TDataSource;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FMode: TProductMode;
    FDatabaseManager: TDatabaseManager;
    procedure SetMode(const Value: TProductMode);
    procedure LoadLookupData;
  public
    property Mode: TProductMode read FMode write SetMode;
  end;

var
  ProductForm: TProductForm;

implementation

{$R *.dfm}

procedure TProductForm.FormCreate(Sender: TObject);
begin
  FDatabaseManager := TDatabaseManager.Create;
  dsCategories := TDataSource.Create(Self);
  dsSuppliers := TDataSource.Create(Self);
  LoadLookupData;
end;

procedure TProductForm.FormDestroy(Sender: TObject);
begin
  FDatabaseManager.Free;
end;

procedure TProductForm.LoadLookupData;
begin
  dsCategories.DataSet := FDatabaseManager.GetCategories;
  dsSuppliers.DataSet := FDatabaseManager.GetSuppliers;
  
  cmbCategory.ListSource := dsCategories;
  cmbCategory.KeyField := 'ID';
  cmbCategory.ListField := 'Name';
  
  cmbSupplier.ListSource := dsSuppliers;
  cmbSupplier.KeyField := 'ID';
  cmbSupplier.ListField := 'Name';
end;

procedure TProductForm.btnSaveClick(Sender: TObject);
begin
  if Trim(edtName.Text) = '' then
  begin
    ShowMessage('Введите название товара');
    Exit;
  end;

  if (Trim(edtQuantity.Text) = '') or (StrToIntDef(edtQuantity.Text, -1) < 0) then
  begin
    ShowMessage('Введите корректное количество');
    Exit;
  end;

  if (Trim(edtPrice.Text) = '') or (StrToFloatDef(edtPrice.Text, 0) <= 0) then
  begin
    ShowMessage('Введите корректную цену');
    Exit;
  end;

  if (Trim(edtMinQuantity.Text) = '') or (StrToIntDef(edtMinQuantity.Text, -1) < 0) then
  begin
    ShowMessage('Введите корректный минимальный порог количества');
    Exit;
  end;

  if not Assigned(cmbCategory.ListSource.DataSet) or 
     (cmbCategory.ListSource.DataSet.RecordCount = 0) then
  begin
    ShowMessage('Необходимо создать хотя бы одну категорию товаров');
    Exit;
  end;

  if not Assigned(cmbSupplier.ListSource.DataSet) or 
     (cmbSupplier.ListSource.DataSet.RecordCount = 0) then
  begin
    ShowMessage('Необходимо создать хотя бы одного поставщика');
    Exit;
  end;

  ModalResult := mrOk;
end;

procedure TProductForm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TProductForm.FormShow(Sender: TObject);
begin
  LoadLookupData;
  
  case FMode of
    pmAdd:
    begin
      Caption := 'Добавить товар';
      edtName.Text := '';
      edtQuantity.Text := '0';
      edtPrice.Text := '0';
      edtMinQuantity.Text := '0';
      edtBarcode.Text := '';
      edtLocation.Text := '';
      memDescription.Text := '';
      if cmbCategory.ListSource.DataSet.RecordCount > 0 then
        cmbCategory.ListSource.DataSet.First;
      if cmbSupplier.ListSource.DataSet.RecordCount > 0 then
        cmbSupplier.ListSource.DataSet.First;
    end;
    pmEdit:
    begin
      Caption := 'Редактировать товар';
    end;
  end;
end;

procedure TProductForm.SetMode(const Value: TProductMode);
begin
  FMode := Value;
end;

end.
