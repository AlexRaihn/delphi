{
  Модуль для работы с базой данных SQLite
  Обеспечивает все операции с данными: создание таблиц, добавление, 
  редактирование, удаление и получение списка товаров
}
unit DatabaseUnit;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.SQLite, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.VCLUI.Wait, FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TDatabaseManager = class
  private
    FConnection: TFDConnection;  // Компонент для подключения к базе данных
    FQuery: TFDQuery;           // Компонент для выполнения SQL-запросов
  public
    constructor Create;
    destructor Destroy; override;
    procedure ConnectDatabase;   // Подключение к базе данных
    procedure CreateTables;      // Создание необходимых таблиц
    procedure AddProduct(const Name: string; Quantity: Integer; Price: Double; CategoryID: Integer; SupplierID: Integer);
    procedure UpdateProduct(ID: Integer; const Name: string; Quantity: Integer; Price: Double; CategoryID: Integer; SupplierID: Integer);
    procedure DeleteProduct(ID: Integer);
    function GetProducts: TFDQuery;
    function GetCategories: TFDQuery;
    function GetSuppliers: TFDQuery;
    function GetTransactions: TFDQuery;
  end;

implementation

constructor TDatabaseManager.Create;
begin
  inherited;
  FConnection := TFDConnection.Create(nil);
  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := FConnection;
  ConnectDatabase;
  CreateTables;
end;

destructor TDatabaseManager.Destroy;
begin
  FQuery.Free;
  FConnection.Free;
  inherited;
end;

procedure TDatabaseManager.ConnectDatabase;
begin
  FConnection.DriverName := 'SQLite';
  FConnection.Params.Database := 'warehouse.db';
  FConnection.Connected := True;
end;

procedure TDatabaseManager.CreateTables;
begin
  // Таблица категорий товаров
  FConnection.ExecSQL(
    'CREATE TABLE IF NOT EXISTS Categories (' +
    'ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
    'Name TEXT NOT NULL, ' +
    'Description TEXT)'
  );

  // Таблица поставщиков
  FConnection.ExecSQL(
    'CREATE TABLE IF NOT EXISTS Suppliers (' +
    'ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
    'Name TEXT NOT NULL, ' +
    'Contact TEXT, ' +
    'Phone TEXT, ' +
    'Email TEXT, ' +
    'Address TEXT)'
  );

  // Таблица товаров с внешними ключами на категории и поставщиков
  FConnection.ExecSQL(
    'CREATE TABLE IF NOT EXISTS Products (' +
    'ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
    'Name TEXT NOT NULL, ' +
    'Quantity INTEGER NOT NULL, ' +
    'Price REAL NOT NULL, ' +
    'CategoryID INTEGER, ' +
    'SupplierID INTEGER, ' +
    'MinQuantity INTEGER DEFAULT 0, ' +  // Минимальный порог количества
    'Description TEXT, ' +               // Описание товара
    'Barcode TEXT, ' +                  // Штрих-код
    'Location TEXT, ' +                 // Место хранения на складе
    'FOREIGN KEY(CategoryID) REFERENCES Categories(ID), ' +
    'FOREIGN KEY(SupplierID) REFERENCES Suppliers(ID))'
  );

  // Таблица складских операций
  FConnection.ExecSQL(
    'CREATE TABLE IF NOT EXISTS Transactions (' +
    'ID INTEGER PRIMARY KEY AUTOINCREMENT, ' +
    'ProductID INTEGER NOT NULL, ' +
    'TransactionType TEXT NOT NULL, ' +  // "IN" или "OUT"
    'Quantity INTEGER NOT NULL, ' +
    'Date DATETIME DEFAULT CURRENT_TIMESTAMP, ' +
    'DocumentNumber TEXT, ' +           // Номер документа
    'Note TEXT, ' +                     // Примечание
    'FOREIGN KEY(ProductID) REFERENCES Products(ID))'
  );
end;

procedure TDatabaseManager.AddProduct(const Name: string; Quantity: Integer; Price: Double; CategoryID: Integer; SupplierID: Integer);
begin
  FQuery.SQL.Text := 'INSERT INTO Products (Name, Quantity, Price, CategoryID, SupplierID) ' +
                     'VALUES (:Name, :Quantity, :Price, :CategoryID, :SupplierID)';
  FQuery.ParamByName('Name').AsString := Name;
  FQuery.ParamByName('Quantity').AsInteger := Quantity;
  FQuery.ParamByName('Price').AsFloat := Price;
  FQuery.ParamByName('CategoryID').AsInteger := CategoryID;
  FQuery.ParamByName('SupplierID').AsInteger := SupplierID;
  FQuery.ExecSQL;
end;

procedure TDatabaseManager.UpdateProduct(ID: Integer; const Name: string; Quantity: Integer; Price: Double; CategoryID: Integer; SupplierID: Integer);
begin
  FQuery.SQL.Text := 'UPDATE Products SET Name=:Name, Quantity=:Quantity, Price=:Price, ' +
                     'CategoryID=:CategoryID, SupplierID=:SupplierID WHERE ID=:ID';
  FQuery.ParamByName('ID').AsInteger := ID;
  FQuery.ParamByName('Name').AsString := Name;
  FQuery.ParamByName('Quantity').AsInteger := Quantity;
  FQuery.ParamByName('Price').AsFloat := Price;
  FQuery.ParamByName('CategoryID').AsInteger := CategoryID;
  FQuery.ParamByName('SupplierID').AsInteger := SupplierID;
  FQuery.ExecSQL;
end;

procedure TDatabaseManager.DeleteProduct(ID: Integer);
begin
  FQuery.SQL.Text := 'DELETE FROM Products WHERE ID=:ID';
  FQuery.ParamByName('ID').AsInteger := ID;
  FQuery.ExecSQL;
end;

function TDatabaseManager.GetProducts: TFDQuery;
begin
  FQuery.SQL.Text := 
    'SELECT P.*, C.Name as CategoryName, S.Name as SupplierName ' +
    'FROM Products P ' +
    'LEFT JOIN Categories C ON P.CategoryID = C.ID ' +
    'LEFT JOIN Suppliers S ON P.SupplierID = S.ID';
  FQuery.Open;
  Result := FQuery;
end;

function TDatabaseManager.GetCategories: TFDQuery;
begin
  FQuery.SQL.Text := 'SELECT * FROM Categories';
  FQuery.Open;
  Result := FQuery;
end;

function TDatabaseManager.GetSuppliers: TFDQuery;
begin
  FQuery.SQL.Text := 'SELECT * FROM Suppliers';
  FQuery.Open;
  Result := FQuery;
end;

function TDatabaseManager.GetTransactions: TFDQuery;
begin
  FQuery.SQL.Text := 
    'SELECT T.*, P.Name as ProductName ' +
    'FROM Transactions T ' +
    'JOIN Products P ON T.ProductID = P.ID ' +
    'ORDER BY T.Date DESC';
  FQuery.Open;
  Result := FQuery;
end;

end.
