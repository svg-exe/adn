# encoding: UTF-8

module ADN
  class Post
    attr_accessor :post_id, :created_at, :entities,
                  :html, :id, :num_replies, :reply_to,
                  :source, :text, :thread_id, :user

    def self.send_post(params)
      result = ADN::API::Post.new(params)
      Post.new(result["data"]) unless ADN.has_error?(result)
    end

    def initialize(raw_post)
      if raw_post.respond_to?(:each_pair)
        self.set_values(raw_post)
        post_id = id
      else
        post_id = raw_post
        details = self.details
        if details.has_key? "data"
          self.set_values(details["data"])
        end
      end
    end

    def details
      if self.id
        h = {}
        self.instance_variables.each do |iv|
          h[iv.to_s.gsub(/[^a-zA-Z0-9_]/, '')] = self.instance_variable_get(iv)
        end
        h
      else
        ADN::API::Post.by_id(post_id)
      end
    end

    def created_at
      DateTime.parse(@created_at)
    end

    def user
      ADN::User.new @user
    end

    def reply_to_post
      result = ADN::API::Post.by_id reply_to
      Post.new(result["data"]) unless ADN.has_error?(result)
    end

    def replies(params = nil)
      result = ADN::API::Post.replies(self.id, params)
      result["data"].collect { |p| Post.new(p) } unless ADN.has_error?(result)
    end

    def delete
      result = ADN::API::Post.delete(self.id)
      Post.new(result["data"]) unless ADN.has_error?(result)
    end
    
    def set_values(values)
      values.each_pair do |k, v|
        self.send("#{k}=", v) if self.respond_to?("#{k}=")
      end
    end
  end
end