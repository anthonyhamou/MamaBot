# coding: utf-8

require 'recastai'
require 'dotenv/load'
require 'pry'
require 'json'
require 'open-uri'
require_relative 'daily_recos.rb'
require_relative 'reco_foryou.rb'
require_relative 'shoppinglist.rb'
require_relative 'search.rb'


def bot(payload)
  connect = RecastAI::Connect.new(ENV['REQUEST_TOKEN'], ENV['LANGUAGE'])
  request = RecastAI::Request.new(ENV['REQUEST_TOKEN'], ENV['LANGUAGE'])

  connect.handle_message(payload) do |message|
    response = request.converse_text(message.content, conversation_token: message.sender_id)
    username = URI.escape(message.message["data"]["userName"])
    sender_id = message.sender_id

    unless response.intent.nil?

      if response.intent.slug
        if response.intent.slug == "suggest-food"
          day_nb = response.entities.select { |entity| entity.value if entity.name == "number_of_day" }.any? ? response.entities.select { |entity| entity.value if entity.name == "number_of_day" }.first.value.gsub(/[^0-9]/, '') : 0
          day = (0 + day_nb.to_i)
          ranking_nb = response.entities.select { |entity| entity.value if entity.name == "rank_nb" }.any? ? response.entities.select { |entity| entity.value if entity.name == "rank_nb" }.first.value.gsub(/[^0-9]/, '') : 0
          ranking = (0 + ranking_nb.to_i)
          if ranking == 0
            messages = suggestions_of_the_day_intro(day)
            connect.send_message(messages, message.conversation_id)
            messages = send_suggestions(day, ranking)
            connect.send_message(messages, message.conversation_id)
          elsif ranking == 5
            messages = next_menu(day)
            connect.send_message(messages, message.conversation_id)
          else
            messages = send_suggestions(day, ranking)
            connect.send_message(messages, message.conversation_id)
          end

        elsif response.intent.slug == "recommend-for-you"
          tags = ["rapide", "léger", "snack", "tarte salée", "gourmand"]
          if ["rapide"].any? { |word| response.source.include?(word) } then  type = "rapide"
            elsif ["léger"].any? { |word| response.source.include?(word) } then  type = "léger"
            elsif ["snack"].any? { |word| response.source.include?(word) } then  type = "snack"
            elsif ["tarte salée"].any? { |word| response.source.include?(word) } then  type = "tarte salée"
            elsif ["gourmand"].any? { |word| response.source.include?(word) } then  type = "gourmand"
            else type = tags.shuffle.take(1)
          end
          messages = send_reco_for_you(type)
          connect.send_message(messages, message.conversation_id)

        elsif response.intent.slug == "search-activation"
          messages = new_search
          connect.send_message(messages, message.conversation_id)

        elsif response.intent.slug == "search-food"
          query = []
          ingredients = response.entities.select { |entity| entity.name == "ingredient" }
          food_types = response.entities.select { |entity| entity.name == "food-type" }
          ingredients.each { |entity| query << "#{entity.value}" }
          food_types.each { |entity| query << "#{entity.value}" }
          query = query.join("+")
          ranking = 0
          messages = search_food(query, ranking)
          connect.send_message(messages, message.conversation_id)

        elsif response.intent.slug == "search-by-id"
          memory = response.entities.select { |entity| entity.name == "recette_id" }
          recipe_id = memory.first.value.gsub(/[^0-9,.]/, "")
          # context => daily_recos
          if response.source.include?("jour_")
            day = response.entities.select { |entity| entity.value if entity.name == "number_of_day" }.any? ? response.entities.select { |entity| entity.value if entity.name == "number_of_day" }.first.value.gsub(/[^0-9]/, '') : 0
            ranking_nb = response.entities.select { |entity| entity.value if entity.name == "rank_nb" }.any? ? response.entities.select { |entity| entity.value if entity.name == "rank_nb" }.first.value.gsub(/[^0-9]/, '') : 0
            ranking = (0 + ranking_nb.to_i)
          # context => search
          elsif response.source.include?("query_")
            # =>>> query => regepx pour récupérer query
            ranking_nb = response.entities.select { |entity| entity.value if entity.name == "rank_nb" }.any? ? response.entities.select { |entity| entity.value if entity.name == "rank_nb" }.first.value.gsub(/[^0-9]/, '') : 0
            ranking = (0 + ranking_nb.to_i)
          # context => reco_foryou
          elsif ["rapide"].any? { |word| response.source.include?(word) } then  type = "rapide"
            elsif ["léger"].any? { |word| response.source.include?(word) } then  type = "léger"
            elsif ["snack"].any? { |word| response.source.include?(word) } then  type = "snack"
            elsif ["tarte salée"].any? { |word| response.source.include?(word) } then  type = "tarte salée"
            elsif ["gourmand"].any? { |word| response.source.include?(word) } then  type = "gourmand"
          end
          messages = send_shopping_list(recipe_id, day, ranking, type, query)
          connect.send_message(messages, message.conversation_id)

        elsif response.intent.slug == "greetings"
          replies = response.replies.map{ |r| { type: 'text', content: r } }
          connect.send_message(replies, message.conversation_id)
          messages = suggestions_options
          connect.send_message(messages, message.conversation_id)

        elsif response.intent.slug == "goodbye"
          replies = response.replies.map{ |r| { type: 'text', content: r } }
          connect.send_message(replies, message.conversation_id)

        elsif response.intent.slug == "suggest-more-options"  || response.intent.slug == "menu"
          messages = suggestions_options
          connect.send_message(messages, message.conversation_id)
        end
      end
    else
      query = message.content
      messages = search_food(query)
      connect.send_message(messages, message.conversation_id)
    end

  end
  200
end
