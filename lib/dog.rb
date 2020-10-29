require 'pry'
class Dog

    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @breed = breed
        @name = name
    end


    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
            #self
        else
        sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
    
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end

    def self.create(hash)
        dog = self.new(hash)
        dog.save
        dog
    end

    def self.new_from_db(row)
        hash = {}
        hash[:name] = row[1]
        hash[:breed] = row[2]
        dog = Dog.new(hash)
        dog.id = row[0]
        dog
      end

      def self.find_by_id(input)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql, input)[0]
        self.new_from_db(result)
      end
       
    def self.find_or_create_by(name:, breed:)
        #this finds ore creates a record in the db class.
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        #[[1, "teddy", "cockapoo"]] dog equals this
        #binding.pry
        if !dog.empty?
            #THIS IS FIND
            dog_data = dog[0]
            self.new_from_db(dog_data)
            #creates a new instance of the dog class, complete with ID since its returned from sql.
 #           binding.pry
        else
            hash = {}
            hash[:name] = name
            hash[:breed] = breed
            dog = self.create(hash)
        end        
    end

    def self.find_by_name(name)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        limit 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
      end

end