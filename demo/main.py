import json
import os.path
import bte
from threading import Thread
from kivy.utils import platform
from kivy.app import App
from kivy.uix.widget import Widget
from kivy.properties import (NumericProperty, ReferenceListProperty, ObjectProperty)
from kivy.vector import Vector
from kivy.clock import Clock
from random import randint
from kivy.properties import StringProperty

class Screen(Widget):
    def __init__(self, p):
        super(Screen, self).__init__()
        self.path = p

    l1 = StringProperty()
    l2 = StringProperty()
    l3 = StringProperty()
    l4 = StringProperty()
    l5 = StringProperty()
    title = StringProperty()

    def update(self, dt):
        try:
            self.read_data()
        except:
            pass
        
    def read_data(self):
        try:
            with open(os.path.join(self.path, 'data.txt')) as f:
                contents = json.loads(f.read())

        except Exception as e:
            contents = {'status': self.path}

        self.title = str(contents.get('status', 'Scanning for compatible wearables...'))
        self.l4 = "pitch: "+ str(contents.get('pitch', '')) #4
        self.l5 = "z: "+ str(contents.get('z', '')) #3
        self.l1 = "y: "+ str(contents.get('y', '')) #2
        self.l2 = "x: "+ str(contents.get('x', '')) #1
        self.l3 = "roll: "+ str(contents.get('roll', '')) #5 4is1, 3is2 2is3 1is4 5is5

class BlApp(App):
    def build(self):
        # self.theme_cls.primary_palette = "Green"
        # self.theme_cls.primary_hue = "A700"
        # self.theme_cls.theme_style = "Light"
        full_path = self.path_stuff()
        screen = Screen(full_path)
        Clock.schedule_interval(screen.update, 1.0/5.0)
        new_thread = Thread(target=bte.main,args=(full_path,))
        new_thread.start()
        return screen

    def path_stuff(self):
        full_path = ''
        if platform == 'ios':
            root_folder = App().user_data_dir
            CACHE_DIR = os.path.join(root_folder, 'cache')
            cache_folder = os.path.join(root_folder, 'cache')
            full_path = cache_folder
        else:
            full_path = "cache"

        if not os.path.exists(full_path):
            os.makedirs(full_path)

        return full_path

if __name__ == "__main__":
    BlApp().run()
