import openai
import os

# Убедитесь, что у вас есть переменная окружения OPENAI_API_KEY
openai.api_key = os.getenv('OPENAI_API_KEY')

def generate_gpt_response(prompt):
    try:
        response = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",  # или используйте другой модель
            messages=[{"role": "user", "content": prompt}],
            max_tokens=150,
            n=1,
            stop=None,
            temperature=0.7,
        )
        return response.choices[0].message['content']
    except Exception as e:
        return f"Error: {str(e)}"