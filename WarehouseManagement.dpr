{ 
  Главный файл проекта складского учета
  Этот файл определяет точку входа в приложение и подключает все необходимые модули
}
program WarehouseManagement;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},     // Главная форма приложения
  ProductUnit in 'ProductUnit.pas' {ProductForm},  // Форма работы с товаром
  DatabaseUnit in 'DatabaseUnit.pas';  // Модуль работы с базой данных

{$R *.res}

begin
  Application.Initialize;  // Инициализация приложения
  Application.MainFormOnTaskbar := True;  // Отображение главной формы на панели задач
  Application.CreateForm(TMainForm, MainForm);  // Создание главной формы
  Application.CreateForm(TProductForm, ProductForm);  // Создание формы товара
  Application.Run;  // Запуск приложения
end.
