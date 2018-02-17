require 'pry'
require 'json'
require 'open-uri'

def send_reco_for_you(type)
  url = "http://www.foodmama.fr/api/v1/recommend?type=#{type}"
  encoded_url = URI.encode(url)
  reco_serialized = open(encoded_url).read
  reco = JSON.parse(reco_serialized)
  content = {
        title: "#{reco["title"].upcase}\n\n📝 #{reco["ingredients"]}",
        buttons: [
          {
            title: 'Voir 👉',
            type: 'web_url',
            value: "#{reco["link"]}"
          },
          {
            title: 'Liste de courses 📝',
            type: 'postback',
            value: "Montres moi la recette id_#{reco['id']} #{type}"
          }
        ]
      }
  messages = [
    {
      type: 'buttons',
      content: content
    },
    {
      type: 'quickReplies',
      content:
      {
        title: "Voir une autre idée ?",
        buttons:
        [
          {
            title: "🍲",
            value: 'donnes-moi une idée rapide'
          },
          {
            title: "🥗",
            value: 'donnes-moi une idée léger'
          },
          {
            title: "🍔",
            value: 'donnes-moi une idée snack'
          },
          {
            title: "🍕",
            value: 'donnes-moi une idée tarte salée'
          },
          {
            title: "😋",
            value: 'donnes-moi une idée gourmand'
          },
          {
            title: "non !",
            value: 'autres options de suggestions'
          }
        ]
      }
    }
  ]
end
