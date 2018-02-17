require 'pry'
require 'json'
require 'open-uri'

def new_search
  messages = [
      {
        type: 'text',
        content: "🔎 un plat ou des ingrédients ? (écris au clavier)"
      }
    ]
end

def search_food(query, ranking)
  encoded_url = URI.encode("http://www.foodmama.fr/api/v1/search?query=#{query}")
  url = URI.parse(encoded_url)
  search_serialized = open(url).read
  search = JSON.parse(search_serialized)
  food = search["food"]["#{ranking}".to_i]
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
            value: "Montres moi la recette id_#{food['id']} rank_#{ranking.to_i} query_#{query}"
          }
        ]
      }
  if content.empty?
     messages = [
      {
        type: 'text',
        content: "😵\nMama n'a pas trouvé...\nTu peux préciser ou me demander autre chose ?"
      }
    ]
  else messages = [
          {
            type: 'buttons',
            content: content
          },
          {
            type: 'quickReplies',
            content:
            {
              title: "Voir un autre résultat ?",
              buttons: [
                {
                  title: 'oui 🔎',
                  value: "je cherche query_#{query} rank_#{ranking.to_i + 1}"
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
end

