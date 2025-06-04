def create_initial_question(photo_info: dict) -> str:
    # 프롬프트 구성 및 openai.ChatCompletion.create(...) 호출
    return "이날 바닷바람을 맞으며 어떤 기분이 드셨나요?"