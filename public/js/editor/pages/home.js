var ui=require('../ui')
  ;

module.exports=function(){
  return {
    onEnter: function(){
      console.log('home#onEnter');

      var el=document.createElement('h1');
      el.setAttribute('class','text-danger');
      el.textContent='home page';

      return el;
    },
  };
};

