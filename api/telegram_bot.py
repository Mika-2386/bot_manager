from telegram import Update
from telegram.ext import Updater, CommandHandler, MessageHandler, CallbackContext, filters
import os
from .utils import generate_gpt_response

TELEGRAM_TOKEN = os.getenv('TELEGRAM_BOT_TOKEN')

def handle_message(update: Update, context: CallbackContext):
    user_text = update.message.text
    reply = generate_gpt_response(user_text)
    update.message.reply_text(reply)

def start_bot():
    updater = Updater(TELEGRAM_TOKEN)
    dispatcher = updater.dispatcher

    dispatcher.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))
    updater.start_polling()
    updater.idle()