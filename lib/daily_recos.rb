require 'pry'
require 'json'
require 'open-uri'
require 'date'


def send_suggestions(day, ranking)
  url = "http://www.foodmama.fr/api/v1/suggest?date=#{day}"
  suggest_serialized = open(url).read
  suggest = JSON.parse(suggest_serialized)
  food = suggest["food"]["#{ranking}".to_i]
  content = {
        title: "#{food["title"].upcase}\n\n📝 #{food["ingredients"]}",
        buttons: [
          {
            title: 'Voir 👉',
            type: 'web_url',
            value: "#{food["link"]}"
          },
          {
            title: 'Liste de courses 📝',
            type: 'postback',
            value: "Montres moi la recette id_#{food['id']} rank_#{ranking.to_i} jour_#{day.to_i}"
          }
        ]
      }
  messages = [
    {
      type: 'text',
      content: "##{ranking.to_i + 1}"
    },
    {
      type: 'buttons',
      content: content
    },
    {
      type: 'quickReplies',
      content:
      {
        title: "Qu'en penses-tu ?",
        buttons:
        [
          {
            title: 'suivant 💖',
            value: "je veux voir les suggestions rank_#{ranking.to_i + 1} du jour_#{day.to_i}"
          },
          {
            title: "ok 👍",
            value: 'autres options de suggestions'
          }
        ]
      }
    }
  ]
end

def suggestions_of_the_day_intro(day)
  date = Date.today + "#{day}".to_i
  messages = [
    {
      type: 'text',
      content: "#{ day == 0 ? "Plats du jour !!\n" : "Plats du #{date.strftime("%d/%m/%Y")} !!" }"
    }
  ]
end

def next_menu(day)
  messages = [
      {
      type: 'quickReplies',
      content:
      {
        title: "Tu as vu les 5 plats du jour !",
        buttons: [
          {
            title: 'revoir ↩️',
            value: "je veux voir les suggestions rank_0 du jour_#{day.to_i}"
          },
          {
            title: "menu suivant 💖",
            value: "je veux voir les suggestions du jour_#{day.to_i + 1}"
          },
          {
            title: "c'est bon 👍",
            value: 'autres options de suggestions'
          }
        ]
      }
    }
  ]
end

def suggestions_options
  messages = [
      {
      type: 'quickReplies',
      content:
      {
        title: "Comment puis-je t'aider ?",
        buttons: [
          {
            title: "Idées repas ⭐",
            value: 'donnes-moi une idée'
          },
          {
            title: "Plats du jour 💖",
            value: 'je veux voir les suggestions du jour 0'
          },
          {
            title: 'Chercher 🔎',
            value: 'activer la recherche'
          }
        ]
      }
    }
  ]
end
