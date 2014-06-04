var ui=require('../ui')
  , api=require('../api')
  , geo=require('./geo')
  ;

var map
  , uiInitialized=false
  , layout
  , search
  ;

module.exports=function(){
  return {
    onEnter: function(){
      var self=this;

      if (!uiInitialized){
        initUI(self);
      }

      map=self.map;


      return layout;
    },
    onExit: function() {
      geo.resetMap(map);
    },
    onStart: function(){
      search.requestFocus();
    },
  };
};

var initUI=function(self){
  var toolbar=ui.button.toolbar();
  var btnBack=ui.button.actionButton('უკან', function(){
    self.openPage('root');
  }, {icon: 'arrow-circle-left'});

  toolbar.addButton(btnBack);
  toolbar.style.marginBottom='8px';

  search=ui.form.textField('search',{placeholder: 'ჩაწერეთ საკვანძო სიტყვა', autofocus: true});
  search.getTextField().onkeyup=function(){
    searching(search.getValue());
  };

  layout=ui.layout.vertical({children: [toolbar,search]});
  uiInitialized=true;
};

var searching=function(text){
  var selected=[];
  if(text){
    var words=text.split(' ');
    map.data.forEach(function(f){
      if(geo.searchHit(f,words)){
        selected.push(f);
      }
    });
  }
  console.log(selected.length);
};