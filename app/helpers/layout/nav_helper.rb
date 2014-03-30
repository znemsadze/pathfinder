# -*- encoding : utf-8 -*-
module Layout::NavHelper
  include Forma::Html
  def nav_menu
    if @nav and @nav.size > 1
      el('ul', attrs: {class: 'breadcrumb'}, children: @nav.each_with_index.map { |(lbl,url), i|
        if i == @nav.size - 1 then el('li', attrs: {class: 'active'}, text: lbl)
        else el('li', children: [el('a', attrs: {href: url}, text: lbl)]) end
      }).to_s
    end
  end
end
