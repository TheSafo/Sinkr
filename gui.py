from Tkinter import *
#import ballsandcups

width = 990
height = 660

class Gui(Frame):
    def __init__(self, parent):
        Frame.__init__(self, parent)
        self.parent = parent
        self.initUI()

    def initUI(self):
        self.parent.title("Sinkr")
        self.pack()
        self.configure(background = 'black')
        canvas = Canvas(self)
        canvas.configure(background = 'black', highlightbackground = 'black')

        c_width = 60
        c_height = c_width

        for i in range (0, 4):
            for j in range (0, 4-i):
                x_pos = c_width * j
                y_pos = c_height * i
                # x_pos = 10 + c_width * j + 15 * i
                # y_pos = 30 + c_height * i
                canvas.create_oval(x_pos, y_pos, x_pos + c_width, y_pos + c_height,
                  outline="white", fill="red", width=2)
        canvas.pack()


def main():
    root = Tk()
    ex = Gui(root)
    root.geometry(str(width) + "x" + str(height))
    ex.parent.configure(background = 'black')
    root.mainloop()

if __name__ == '__main__':
    main()
