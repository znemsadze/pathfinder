var ui=require('../ui')
  ;

var titleElement=ui.html.pageTitle('საწყისი');

module.exports=function(){
  return {
    onEnter: function(){
      console.log('home#onEnter');

      var layout=ui.layout.vertical({
        children: [
          titleElement,
        ]
      });

      return layout;
    },
  };
};
