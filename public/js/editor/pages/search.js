var ui=require('../ui')
  , api=require('../api')
  , geo=require('./geo')
  ;

var map
  , uiInitialized=false
  , layout
  , search
  , results
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

  results=ui.html.el('div',{style: 'position:absolute; top:90px; bottom: 0; left:0; right: 0; padding: 4px 8px; overflow: auto; background: #fafafa;'});

  layout=ui.layout.vertical({children: [toolbar,search, results]});
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
  results.innerText="Results: "+selected.length;
};