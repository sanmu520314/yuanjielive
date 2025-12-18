

import 'package:get/get.dart';

import 'getx_controller_inject.dart';


///刷新状态
enum Refresh {
  ///初次进入页面加载
  first,

  ///上拉加载
  pull,

  ///下拉加载
  down,
}

class BaseGetPageController extends BaseGetController{

  ///加载状态  0加载中 1加载成功 2加载数据为空 3加载失败
  var loadState = 0.obs;
  ///当前页数
  int page = 1;
  ///是否初次加载
  var isInit = true;



  ///加载成功，是否显示空页面
  showSuccess(List suc){
    loadState.value = suc.isNotEmpty ? 1 : 2;
  }

  ///加载失败,显示失败页面
  showError(){
    loadState.value = 3;
  }

  ///重新加载
  showLoading(){
    loadState.value = 0;
  }


}