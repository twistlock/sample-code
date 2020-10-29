from sanic import Sanic
from sanic.response import json
from sanic_openapi import swagger_blueprint

app = Sanic(name='pet app')
app.blueprint(swagger_blueprint)


@app.get("/dog")

class Pet(object):
    
    def __init__(self, name, species):
        self.name = name
        self.species = species


    def getName(self):
        return self.name

    def getSpecies(self):
        return self.species

    def __str__(self):
        return "%s is a %s" % (self.name, self.species)

class Dog(Pet):
    
    def __init__(self, name, chases_cats):
        Pet.__init__(self, name, "Dog")
        self.chases_cats = chases_cats

    def chasesCats(self):
        return self.chases_cats

class Cat(Pet):
    def __init__(self, name, hates_dogs):
        Pet.__init__(self, name, "Cat")
        self.hates_dogs = hates_dogs

    def hatesDogs(self):
        return self.hates_dogs

class Parrot(Pet):
    pass




if __name__ == '__main__':
    # Polly the Parrot
    polly = Pet("Polly", "Parrot")
    print polly.getName()
    print polly.getSpecies()
    print polly

    # Ginger the Cat
    ginger = Pet("Ginger", "Cat")
    print ginger.getName()
    print ginger.getSpecies()
    print ginger

    # Clifford the Dog
    clifford = Pet("Clifford", "Dog")
    print clifford.getName()
    print clifford.getSpecies()
    print clifford

    # Using subclasses -- we can create a Pet called Mister who is also a Dog,
    # or we can create a Dog called Mister who chases cats.
    mister_pet = Pet("Mister", "Dog")
    mister_dog = Dog("Mister", True)

    # Mister (the pet) is not an instance of the 'Dog' class, but Mister (the
    # dog) is an instance of both the 'Dog' and 'Pet' classes.
    print isinstance(mister_pet, Pet)
    print isinstance(mister_pet, Dog)
    print isinstance(mister_dog, Pet)
    print isinstance(mister_dog, Dog)

    # Error - 'Pet' doesn't have a method 'chasesCats', only 'Dog' does print
    # mister_pet.chasesCats()
    print mister_dog.chasesCats()
    print mister_pet.getName()
    print mister_dog.getName()

    # Some more animals -- demonstrating the different ways you can subclass
    # things.
    fido = Dog("Fido", True)
    rover = Dog("Rover", False)
    mittens = Cat("Mittens", True)
    fluffy = Cat("Fluffy", False)
    print fido
    print rover
    print mittens
    print fluffy
    print "%s chases cats: %s" % (fido.getName(), fido.chasesCats())
    print "%s chases cats: %s" % (rover.getName(), rover.chasesCats())
    print "%s hates dogs: %s" % (mittens.getName(), mittens.hatesDogs())
    print "%s hates dogs: %s" % (fluffy.getName(), fluffy.hatesDogs())

