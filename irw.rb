# -*- coding: utf-8 -*
require_relative 'setting'

Plugin.create(:irw) do
  ignore = 1..8

  Thread.new do
    IO.popen('irw') do |irw|
      loop do
        _raw, count, key, controller = irw.gets.split(' ')
        if !(ignore === count)
          Plugin.call(:irw_key_pushed, controller, key)
        end
      end
    end
  end

  settings "リモコン" do
    listview = Plugin::Irw::Setting.new(Plugin[:shortcutkey])
    filter_entry = listview.filter_entry = Gtk::Entry.new
    filter_entry.primary_icon_pixbuf = Gdk::WebImageLoader.pixbuf(MUI::Skin.get("search.png"), 24, 24)
    filter_entry.ssc(:changed){
      listview.model.refilter
    }
    pack_start(Gtk::VBox.new(false, 4).
                closeup(filter_entry).
                add(Gtk::HBox.new(false, 4).
                     add(listview).
                     closeup(listview.buttons(Gtk::VBox))))
  end

end
