require 'pry'
require 'json'
require 'open-uri'

def send_shopping_list(id, day, ranking, type, query)
  url = "http://www.foodmama.fr/api/v1/select?recipe=#{id}"
  encoded_url = URI.encode(url)
  shoppinglist_serialized = open(encoded_url).read
  shoppinglist = JSON.parse(shoppinglist_serialized)
  content = {
      type: 'buttons',
      content:
      {
        title: "#{shoppinglist["title"].upcase} \n📝 pour #{shoppinglist["servings"].to_s} pers.\n\n- " + shoppinglist["ingredients"].join("\n- "),
        buttons: [
          {
            title: 'Voir 👉',
            type: 'web_url',
            value: "#{shoppinglist["link"]}"
          }
        ]
      }
    }
  if ranking && day
      reply =
        {
          type: 'quickReplies',
          content:
            {
              title: "Voir les autres plats ?",
              buttons:
              [
                {
                  title: "c'est bon 👍",
                  value: 'autres options de suggestions'
                },
                {
                  title: 'plat suivant 💖',
                  value: "je veux voir les suggestions rank_#{ranking.to_i + 1} du jour_#{day.to_i}"
                }
              ]
            }
          }
  elsif ranking && !day
      reply =
        {
          type: 'quickReplies',
          content:
            {
              title: "Voir un autre résultat ?",
              buttons:
              [
                {
                  title: 'oui 🔎',
                  value: "je cherche #{query} rank_#{ranking.to_i + 1}"
                },
                {
                  title: "non !",
                  value: 'autres options de suggestions'
                }
              ]
            }
          }
    elsif type
      reply =
        {
          type: 'quickReplies',
          content:
          {
            title: "Voir une autre idée ?",
            buttons:
            [
              {
                title: "c'est bon 👍",
                value: 'autres options de suggestions'
              },
              {
                title: 'autre idée ⭐',
                value: "donnes-moi une idée #{type}"
              }
            ]
          }
        }
  end
  return messages = [ content, reply ]
end
