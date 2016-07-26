# -*- coding: utf-8 -*-
miquire :mui, 'extension'

require 'gtk2'

class Plugin::Irw::IrConfig < Gtk::Button

  attr_accessor :change_hook, :title

  def initialize(title, default_key="", *args)
    mainthread_only
    @title = title
    if(default_key.respond_to?(:to_s))
      self.keycode = default_key.to_s
    else
      self.keycode = '' end
    @change_hook = nil
    super(*args)
    self.add(buttonlabel)
    self.signal_connect('clicked', &method(:clicked_event))
  end

  def buttonlabel
    @buttonlabel ||= Gtk::Label.new(keycode) end

  attr_reader :keycode
  def keycode=(other)
    type_strict other => String
    @keycode = other
  end

  private

  def clicked_event(event)
    box = Gtk::VBox.new
    label = Gtk::Label.new
    button = Gtk::Button.new
    dialog = Gtk::Dialog.new(title, self.get_ancestor(Gtk::Window), Gtk::Dialog::MODAL,
                             [ Gtk::Stock::OK, Gtk::Dialog::RESPONSE_OK])
    label.text = keycode
    box.border_width = 20
    button.add(label)
    box.pack_start(Gtk::Label.new('割り当てたいリモコンのボタンを押してください。'))
    box.pack_start(button)
    dialog.vbox.add(box)
    dialog.show_all
    dialog.run
    dialog.destroy end

  def key_set(label)
    lambda{ |widget, event|
      self.keycode = Gtk.keyname([event.keyval, event.state])
      buttonlabel.text = label.text = keycode
      self.change_hook.call(keycode) if self.change_hook
      true }
  end

  def button_set(label)
    lambda{ |widget, event|
      self.keycode = Gtk.buttonname([event.event_type, event.button, event.state])
      buttonlabel.text = label.text = keycode
      self.change_hook.call(keycode) if self.change_hook
      true }
  end

end
