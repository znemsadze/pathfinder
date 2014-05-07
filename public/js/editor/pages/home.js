var ui=require('../ui')
  ;

var titleElement=ui.html.pageTitle('საწყისი');
var toolbar=ui.button.toolbar([]);

module.exports=function(){
  return {
    onEnter: function(){
      console.log('home#onEnter');

      var btnNewPath=ui.button.actionButton('New Path', function(){
        console.log('open new path page');
      }, {icon:'plus'});

      toolbar.addButton(btnNewPath);

      var layout=ui.layout.vertical({
        children: [
          titleElement,
          toolbar,
        ]
      });

      return layout;
    },
  };
};
