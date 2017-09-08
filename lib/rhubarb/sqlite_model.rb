require "sqlite3"
require "rhubarb/util"

DB = SQLite3::Database.new("test.db")

module Rhubarb
  module Model
    class SQLite

      def initialize(data = nil)
        @hash = data
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def save!
        unless @hash["id"]
          self.class.create
          return true
        end

        fields =
          @hash.map do |k, v|
            "#{k}=#{self.class.to_sql(v)}"
          end.join(",")

        DB.execute <<-SQL
          UPDATE #{self.class.table}
          SET #{fields}
          WHERE id = #{@hash["id"]}
        SQL

        true
      end

      def save
        self.save! rescue false
      end

      def method_missing(name, *args)
        if @hash.keys.include?(name.to_s)
          self.class.class_eval do
            define_method(name) do
              self[name]
            end
          end
          self.send(name)
        end

        if name.to_s[-1] == "="
          self.class.class_eval do
            define_method(name) do |value|
              self[name.to_s.chomp("=")] = value
            end
          end
          self.send(name, args[0])
        end
      end

      def self.to_sql(val)
        case val
        when NilClass
          'null'
        when Numeric
          val.to_s
        when String
          "'#{val}'"
        else
          raise "Can't change #{val.class} to SQL!"
        end
      end

      def self.find(id)
        row =
          DB.execute <<-SQL
            SELECT #{schema.keys.join(",")}
            FROM #{table}
            WHERE id = #{id.to_i}
          SQL

        data = Hash[schema.keys.zip(row[0])]
        self.new(data)
      end

      def self.create(values)
        values.delete("id")
        keys = schema.keys - ["id"]
        vals = keys.map do |key|
          to_sql(values[key])
        end

        DB.execute <<-SQL
          INSERT INTO #{table} (#{keys.join(",")})
          VALUES (#{vals.join(",")})
        SQL

        raw_vals = keys.map { |k| values[k] }
        data = Hash[keys.zip(raw_vals)]
        sql = "SELECT last_insert_rowid();"
        data["id"] = DB.execute(sql)[0][0]
        self.new(data)
      end

      def self.count
        DB.execute(<<-SQL)[0][0]
          SELECT COUNT(*) FROM #{table};
        SQL
      end

      def self.table
        Rhubarb.to_underscore(name)
      end

      def self.schema
        return @schema if @schema

        @schema = {}
        DB.table_info(table) do |row|
          @schema[row["name"]] = row["type"]
        end
        @schema
      end

    end
  end
end
