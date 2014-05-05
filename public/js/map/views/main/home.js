var forma=require('../../forma');

var mModel
  , mDelegate
  ;

module.exports=function(model,delegate){
  mModel=model;
  mDelegate=delegate;

  initUI();

  return mLayout;
};

var mLayout
  , mTitle
  , mToolbar
  , mBtnNewPoint
  ;

var initUI=function(){
  mTitle=forma.pageTitle('საწყისი');

  mBtnNewPoint=forma.actionButton([forma.faIcon('plus'),' ახალი წერტილი'], mDelegate&&mDelegate.onNewPoint);
  mToolbar=forma.toolbar([mBtnNewPoint]);

  mLayout=forma.verticalLayout([mTitle,mToolbar]);
};