var map
  , sidebar
  , filters
  , currentPage
  , pages={}
  ;

exports.initApplication=function(opts){
  map=opts.map;
  filters=opts.filters;
  sidebar=opts.sidebar;
  return {
    addPage: addPage,
    openPage: openPage,
  };
};

exports.filterChanged=function(){
  if(currentPage&&currentPage.filterChanged){
    currentPage.filterChanged();
  }
};

var addPage=function(name,page){
  page.openPage=openPage;
  pages[name]=page;
};

var openPage=function(name,params){
  // exiting currently open page
  if(currentPage){
    if(currentPage.onPause){
      var resp=currentPage.onPause();
      if(resp===false){ return; }
    }
    if(currentPage.onExit){
      currentPage.onExit();
    }
    currentPage.params={};
  }

  // clear sidebar
  sidebar.innerText='';

  // opening new page
  currentPage=pages[name];

  currentPage.map=map;
  currentPage.filters=filters;

  if(currentPage){
    currentPage.params=params;
    if(currentPage.onEnter){
      var pageLayout=currentPage.onEnter();
      sidebar.appendChild(pageLayout);
    }
    if(currentPage.onStart){
      currentPage.onStart();
    }
  }
};
