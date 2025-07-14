#creating a string

name = 'N'
print (name)
print (len(name))

greetings = "Welcome in this python world"
print (greetings)
print (len(greetings))

multiline_string = """ Hi, I am Neeraj Kr.
I working as DevOps engineer and trying to learn python.
taking 30 days challenge"""

print (multiline_string)
print (len(multiline_string))

# String Concatenations

name = 'Neeraj'
middle = 'Kr'
surname = 'Jolly'
print (name, middle, surname)
print (len(middle) > len(surname))
print (len(name) > len(surname))

# Scape Sequance 

print ('I am gonna be expert in python and gonna build the good logic with programming.\nwhat about you')
print ('Neeraj \tKumar')
print ('Hello \\Kumar')
print ('Hello \'Kumar\'')
print ('How are \"you\"')


print ('###### here is the scape squenace practice ######')
print ('Days\tTopic\t\tStatus')
print ('Day 1\tIntro\t\tDone')
print ('Day 2\tVariables\tWIP')
print ('Day 3\tOperators\tDone')
print ('This is blackslash - \\')
print ('This is double qoutes - \"')


print ('####### String Formatting#########')
first_name = 'Neeraj'
last_name = 'Kumar'
language ='Python'
formated = 'I am %s %s. I teach %s' %(first_name, last_name, language)