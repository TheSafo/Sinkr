from Tkinter import *
#import ballsandcups


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

        for i in range (0, 4):
            for j in range (0, 4-i):
                x_pos = 10 + 30 * j + 15 * i
                y_pos = 30 + 28 * i
                canvas.create_oval(x_pos, y_pos, x_pos + 30, y_pos + 30,
                  outline="white", fill="red", width=2)
        canvas.pack()


def main():
    root = Tk()
    ex = Gui(root)
    root.geometry("990x660")
    ex.parent.configure(background = 'black')
    root.mainloop()

if __name__ == '__main__':
    main()
