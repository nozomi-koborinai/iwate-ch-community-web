class UtilsBase<T> {
  static UtilsBase get instance => _generationInstance();
  static UtilsBase? _instance;
  static UtilsBase _generationInstance() {
    //インスタンスが生成されていない場合はインスタンスを生成
    _instance ??= UtilsBase();
    //インスタンス化された_instanceを返却
    return _instance!;
  }
}
