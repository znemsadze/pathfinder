var html=require('./html')
  , icon=require('./icon')
  , button=require('./button')
  , page=require('./page')
  , form=require('./form');

// standard html elements
exports.pageTitle=html.pageTitle

// icon
exports.faIcon=icon.faIcon;

// buttons
exports.actionButton=button.actionButton;
exports.actionLink=button.actionLink;
exports.buttonGroup=button.buttonGroup;
exports.dropdown=button.dropdown;
exports.toolbar=button.toolbar;

// page
exports.verticalLayout=page.verticalLayout;

// form
exports.textField=form.textField;