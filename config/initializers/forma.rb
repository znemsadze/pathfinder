# -*- encoding : utf-8 -*-
DATE_FORMAT = '%d-%b-%Y %T %Z'

module SystemFields
  def timestamps
    date_field(:created_at, label: I18n.t('models.general.created_at'), hint: I18n.t('models.general.created_at_hint'), required: true, formatter: DATE_FORMAT)
    date_field(:updated_at, label: I18n.t('models.general.updated_at'), hint: I18n.t('models.general.updated_at_hint'), required: true, formatter: DATE_FORMAT)
  end

  def userstamps
    text_field(:creator, label: I18n.t('models.general.created_by'), hint: I18n.t('models.general.created_by_hint'), required: true)
    text_field(:updater, label: I18n.t('models.general.updated_by'), hint: I18n.t('models.general.updated_by_hint'), required: true)
  end

  def organization
    complex_field(name: 'organization', required: true, label: I18n.t('models.general.organization'), hint: I18n.t('models.general.organization_hint')) do |c|
      c.text_field 'organization.tin', tag: 'code'
      c.text_field 'organization.name'
    end
  end
end

module HandyFields
  def boolean_options(name, opts = {})
    combo_field name, { empty: false, collection: {
      I18n.t('models.general.boolean_empty') => nil,
      I18n.t('models.general.boolean_true') => 'true',
      I18n.t('models.general.boolean_false') => 'false'
    } }.merge( opts )
  end
end

module CommonActions
  def save_button
    submit I18n.t('models.general._actions.save')
  end

  def cancel_button(url, h={})
    h[:confirm] = I18n.t('models.general._actions.cancel_confirm') if h[:confirm] == true
    bottom_action(
      url,
      label: I18n.t('models.general._actions.cancel'),
      icon: '/icons/cross.png',
      confirm: h[:confirm]
    )
  end

  def edit_action(url, opts = {})
    icon = opts[:icon] || '/icons/pencil.png'
    label = opts[:label] || I18n.t('models.general._actions.edit')
    if respond_to?(:title_action)
      title_action url, opts.merge(icon: icon, label: label)
    else
      action url, opts.merge(icon: icon, label: label)
    end
  end

  def delete_action(url)
    if respond_to?(:title_action)
      title_action url, method: 'delete', icon: '/icons/bin.png', label: I18n.t('models.general._actions.delete'), confirm: I18n.t('models.general._actions.confirm')
    else
      action url, method: 'delete', icon: '/icons/bin.png', label: I18n.t('models.general._actions.delete'), confirm: I18n.t('models.general._actions.confirm')
    end
  end

  def copy_action(url)
    if respond_to?(:title_action)
      title_action url, icon: '/icons/documents-text.png', label: I18n.t('models.general._actions.copy')
    else
      action url, icon: '/icons/documents-text.png', label: I18n.t('models.general._actions.copy')
    end
  end

  def plus_action(url)
    if respond_to?(:title_action)
      title_action url, icon: '/icons/plus.png', label: I18n.t('models.general._actions.plus')
    else
      action url, icon: '/icons/plus.png', label: I18n.t('models.general._actions.plus')
    end
  end
end

class Forma::Form
  include SystemFields
  include HandyFields
  include CommonActions
end

class Forma::Tab
  include SystemFields
  include HandyFields
  include CommonActions
end

class Forma::Col
  include SystemFields
  include HandyFields
  include CommonActions
end

class Forma::Field
  include CommonActions
end

class Forma::Table
  def edit_action(url, opts = {})
    item_action url, opts.merge(icon: '/icons/pencil.png', tooltip: I18n.t('models.general._actions.edit'))
  end

  def delete_action(url, opts = {})
    item_action url, opts.merge(method: 'delete', icon: '/icons/bin.png', tooltip: I18n.t('models.general._actions.delete'), confirm: I18n.t('models.general._actions.confirm'))
  end
end