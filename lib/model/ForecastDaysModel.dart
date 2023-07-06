class ForecastDaysModel{
  var _dateTime;
  var _temp;
  String _main;
  String _description;

  ForecastDaysModel(this._dateTime, this._temp, this._main, this._description);

  String get description => _description;

  String get main => _main;

  get temp => _temp;

  get dateTime => _dateTime;
}