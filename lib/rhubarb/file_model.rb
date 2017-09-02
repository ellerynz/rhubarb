require "multi_json"

module Rhubarb
  module Model
    class FileModel

      def initialize(filename)
        @filename = filename

        # If filename is dir/1.json then @id is 1
        basename = File.split(filename)[-1]
        @id = File.basename(basename, ".json").to_i

        obj = File.read(filename)
        @hash = MultiJson.load(obj)
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def self.find(id)
        begin
          FileModel.new("db/quotes/#{id}.json")
        rescue
          return nil
        end
      end

      def self.all
        files.map { |f| FileModel.new(f) }
      end

      def self.files
        Dir["db/quotes/*.json"]
      end

      def self.create(attrs)
        hash =
          {}.tap do |h|
            h["submitter"]   = attrs["submitter"]   || ""
            h["quote"]       = attrs["quote"]       || ""
            h["attribution"] = attrs["attribution"]
          end

        highest_id =
          files.
            # Last string after the slash e.g. '1.json'
            map { |f| f.split("/")[-1] }.
            # Drop the file extension and convert
            map(&:to_i).
            max

        new_filename = "db/quotes/#{highest_id+1}.json"

        File.open(new_filename, "w") do |f|
          f.write(MultiJson.dump(hash))
        end

        FileModel.new(new_filename)
      end

    end
  end
end
