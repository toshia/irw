# -*- coding: utf-8 -*
require_relative 'setting'

Plugin.create(:irw) do
  ignore = 1..8

  Thread.new do
    IO.popen('irw') do |irw|
      loop do
        _raw, count, key, controller = irw.gets.split(' ')
        notice "#{count}, #{key}, #{controller}"
        if !(ignore === count.to_i(16))
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

  on_irw_key_pushed do |controller, key|
    command = "#{controller} #{key}"
    notice "pass1 #{command}"
    keybinds = (UserConfig[:remocon_keybinds] || Hash.new)
    commands = lazy{ Plugin.filtering(:command, Hash.new).first }
    widget = Plugin::GUI::Window.active.active_chain.last
    timeline = widget.is_a?(Plugin::GUI::Timeline) ? widget : widget.active_class_of(Plugin::GUI::Timeline)
    event = Plugin::GUI::Event.new(:irw, widget, timeline ? timeline.selected_messages : [])
    keybinds.values.each{ |behavior|
      if behavior[:key] == command
        cmd = commands[behavior[:slug]]
        if cmd and widget.class.find_role_ancestor(cmd[:role]) and cmd[:condition] === event
          cmd[:exec].call(event)
          break end end }
  end
end
