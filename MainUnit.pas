{
  Главная форма приложения складского учета
  Отображает список товаров и предоставляет интерфейс для управления ими
}
unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.DBGrids, Vcl.StdCtrls,
  Vcl.ExtCtrls, Data.DB, DatabaseUnit, Vcl.ComCtrls;

type
  TMainForm = class(TForm)
    PageControl1: TPageControl;
    
    // Вкладка товаров
    tabProducts: TTabSheet;
    Panel1: TPanel;
    btnAddProduct: TButton;
    btnEditProduct: TButton;
    btnDeleteProduct: TButton;
    btnRefresh: TButton;
    ProductGrid: TDBGrid;
    dsProducts: TDataSource;
    
    // Вкладка категорий
    tabCategories: TTabSheet;
    Panel2: TPanel;
    btnAddCategory: TButton;
    btnEditCategory: TButton;
    btnDeleteCategory: TButton;
    CategoryGrid: TDBGrid;
    dsCategories: TDataSource;
    
    // Вкладка поставщиков
    tabSuppliers: TTabSheet;
    Panel3: TPanel;
    btnAddSupplier: TButton;
    btnEditSupplier: TButton;
    btnDeleteSupplier: TButton;
    SupplierGrid: TDBGrid;
    dsSuppliers: TDataSource;
    
    // Вкладка операций
    tabTransactions: TTabSheet;
    Panel4: TPanel;
    btnAddTransaction: TButton;
    TransactionGrid: TDBGrid;
    dsTransactions: TDataSource;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAddProductClick(Sender: TObject);
    procedure btnEditProductClick(Sender: TObject);
    procedure btnDeleteProductClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    FDatabaseManager: TDatabaseManager;
    procedure RefreshData;
  public
  end;

var
  MainForm: TMainForm;

implementation

uses ProductUnit;

{$R *.dfm}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FDatabaseManager := TDatabaseManager.Create;
  
  dsProducts := TDataSource.Create(Self);
  dsCategories := TDataSource.Create(Self);
  dsSuppliers := TDataSource.Create(Self);
  dsTransactions := TDataSource.Create(Self);
  
  RefreshData;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FDatabaseManager.Free;
end;

procedure TMainForm.RefreshData;
begin
  case PageControl1.ActivePageIndex of
    0: dsProducts.DataSet := FDatabaseManager.GetProducts;
    1: dsCategories.DataSet := FDatabaseManager.GetCategories;
    2: dsSuppliers.DataSet := FDatabaseManager.GetSuppliers;
    3: dsTransactions.DataSet := FDatabaseManager.GetTransactions;
  end;
end;

procedure TMainForm.PageControl1Change(Sender: TObject);
begin
  RefreshData;
end;

procedure TMainForm.btnAddProductClick(Sender: TObject);
begin
  ProductForm.Mode := pmAdd;
  if ProductForm.ShowModal = mrOk then
  begin
    FDatabaseManager.AddProduct(
      ProductForm.edtName.Text,
      StrToIntDef(ProductForm.edtQuantity.Text, 0),
      StrToFloatDef(ProductForm.edtPrice.Text, 0),
      ProductForm.cmbCategory.KeyValue,
      ProductForm.cmbSupplier.KeyValue
    );
    RefreshData;
  end;
end;

procedure TMainForm.btnEditProductClick(Sender: TObject);
begin
  if not Assigned(dsProducts.DataSet) or (dsProducts.DataSet.RecordCount = 0) then Exit;

  ProductForm.Mode := pmEdit;
  ProductForm.edtName.Text := dsProducts.DataSet.FieldByName('Name').AsString;
  ProductForm.edtQuantity.Text := dsProducts.DataSet.FieldByName('Quantity').AsString;
  ProductForm.edtPrice.Text := dsProducts.DataSet.FieldByName('Price').AsString;
  ProductForm.edtMinQuantity.Text := dsProducts.DataSet.FieldByName('MinQuantity').AsString;
  ProductForm.edtBarcode.Text := dsProducts.DataSet.FieldByName('Barcode').AsString;
  ProductForm.edtLocation.Text := dsProducts.DataSet.FieldByName('Location').AsString;
  ProductForm.memDescription.Text := dsProducts.DataSet.FieldByName('Description').AsString;
  ProductForm.cmbCategory.KeyValue := dsProducts.DataSet.FieldByName('CategoryID').AsInteger;
  ProductForm.cmbSupplier.KeyValue := dsProducts.DataSet.FieldByName('SupplierID').AsInteger;

  if ProductForm.ShowModal = mrOk then
  begin
    FDatabaseManager.UpdateProduct(
      dsProducts.DataSet.FieldByName('ID').AsInteger,
      ProductForm.edtName.Text,
      StrToIntDef(ProductForm.edtQuantity.Text, 0),
      StrToFloatDef(ProductForm.edtPrice.Text, 0),
      ProductForm.cmbCategory.KeyValue,
      ProductForm.cmbSupplier.KeyValue
    );
    RefreshData;
  end;
end;

procedure TMainForm.btnDeleteProductClick(Sender: TObject);
begin
  if not Assigned(dsProducts.DataSet) or (dsProducts.DataSet.RecordCount = 0) then Exit;

  if MessageDlg('Вы уверены, что хотите удалить этот товар?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    FDatabaseManager.DeleteProduct(dsProducts.DataSet.FieldByName('ID').AsInteger);
    RefreshData;
  end;
end;

procedure TMainForm.btnRefreshClick(Sender: TObject);
begin
  RefreshData;
end;

end.
