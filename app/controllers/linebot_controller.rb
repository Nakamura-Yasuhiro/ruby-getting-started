class LinebotController < ApplicationController
     require "line/bot"  # gem "line-bot-api"
 
     # callbackアクションのCSRFトークン認証を無効
     protect_from_forgery :except => [:callback]
 
     def client
       @client ||= Line::Bot::Client.new { |config|
         config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
         config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
       }
     end
     
     def callback 
       body = request.body.read
   
       signature = request.env["HTTP_X_LINE_SIGNATURE"]
       unless client.validate_signature(body, signature)
         error 400 do "Bad Request" end
       end
   
       events = client.parse_events_from(body)
   
       events.each { |event|
         case event
         when Line::Bot::Event::Message
           case event.type
           when Line::Bot::Event::MessageType::Text
                if event.message["text"].include?("健康診断")
                    client.reply_message(event['replyToken'], template)
                        
                
                # elsif event.message["text"].include?("はい")
                #     message = {
                #         type: "text",
                #         text: "では紹介する相手を選んでください"
                #     }
                        
                # elsif event.message["text"].include?("いいえ")
                #     message = {
                #         type: "text",
                #         text: "私の出る幕はないようです"
                #     }
                # elsif event.message["text"].include?("中村さんに診察を受けさせたい")
                #     message = {
                #         type: "text",
                #         text: "それでは催促メッセージを送ります"
                #     }
                end
                
                client.reply_message(event["replyToken"], message)

           when Line::Bot::Event::MessageType::Location
             message = {
               type: "location",
               title: "あなたはここにいますか？",
               address: event.message["address"],
               latitude: event.message["latitude"],
               longitude: event.message["longitude"]
             }
             client.reply_message(event["replyToken"], message)
           end
         when Line::Bot::Event::MemberJoined # join
         

            messages = [{
                type: "image",
                originalContentUrl: "https://yossy-style.net/wp-content/uploads/2017/07/IMG_6074.jpg",
                previewImageUrl: "https://yossy-style.net/wp-content/uploads/2017/07/IMG_6074.jpg"
            }]
            
            client.reply_message(event["replyToken"], messages)
         end
         
       }
   
       head :ok
     end
     
       private

  def template
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
          "type": "confirm",
          "text": "健康診断ですか？",
          "actions": [
              {
                "type": "message",
                # Botから送られてきたメッセージに表示される文字列です。
                "label": "はい",
                # ボタンを押した時にBotに送られる文字列です。
                "text": "いいえ"
              },
              {
                "type": "message",
                "label": "では紹介する相手を選んでください",
                "text": "そうですか"
              }
          ]
      }
    }
  end
     
 end