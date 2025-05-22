import requests
import json
import base64
import os
import tiktoken
from dataclasses import dataclass, asdict
from typing import List, Optional, Dict, Any
from dotenv import load_dotenv
from openai import AzureOpenAI

# 환경 변수 로드
load_dotenv()

# 데이터 클래스 정의
@dataclass
class Metadata:
    width: int
    height: int

@dataclass
class BoundingBox:
    x: int
    y: int
    w: int
    h: int
C:\Users\blank\OneDrive\Desktop\3차 프로젝트\3rd
@dataclass
class CaptionResult:
    text: str
    confidence: float

@dataclass
class DenseCaptionValue:
    text: str
    confidence: float
    boundingBox: BoundingBox

@dataclass
class DenseCaptionResult:
    values: List[DenseCaptionValue]

# 이미지 분석 클래스
class ImageAnalysis:
    def __init__(self):
        self.endpoint = os.getenv("endpoint")
        self.key = os.getenv("key")
        
        if not self.endpoint or not self.key:
            raise ValueError("Please set the endpoint and key in the environment variables.")
        
        # Headers for binary image data
        self.headers_binary = {
            'Ocp-Apim-Subscription-Key': self.key,
            'Content-Type': 'application/octet-stream'
        }
    
    def analyze_local_image(self, image_path, features=["caption", "denseCaptions"]):
        """로컬 이미지 분석 및 결과 반환"""
        features_str = ",".join(features)
        url = f"{self.endpoint}computervision/imageanalysis:analyze?features={features_str}&gender-neutral-caption=false&api-version=2023-10-01"
        
        try:
            # 이미지 파일을 바이너리로 읽기
            with open(image_path, 'rb') as image_file:
                image_data = image_file.read()
            
            # API 요청 전송
            response = requests.post(url, headers=self.headers_binary, data=image_data)
            response.raise_for_status()  # HTTP 오류 확인
            data = response.json()
            
            return self._process_response(data)
            
        except FileNotFoundError:
            print(f"Error: 이미지 파일을 찾을 수 없습니다: {image_path}")
            return None
        except requests.exceptions.RequestException as e:
            print(f"API 요청 오류: {e}")
            return None
        except json.JSONDecodeError:
            print("응답을 JSON으로 파싱할 수 없습니다.")
            return None
        except Exception as e:
            print(f"오류 발생: {e}")
            return None
    
    def _process_response(self, data):
        """API 응답 처리 및 캡션/상세 캡션 추출"""
        try:
            caption = ""
            dense_captions = []
            
            if 'captionResult' in data:
                caption = data['captionResult']['text']
                print(f"\nCaption: {caption}")
            
            if 'denseCaptionsResult' in data:
                print("\nDense Captions:")
                for value in data['denseCaptionsResult']['values']:
                    dense_captions.append(value['text'])
                    print(f"- {value['text']}")
            
            return {
                "caption": caption,
                "dense_captions": dense_captions,
                "raw_data": data
            }
                
        except KeyError as e:
            print(f"KeyError: {e}. 응답 구조를 확인하세요.")
            return None


class LLMDescription:
    def __init__(self):
        # Azure OpenAI 관련 설정
        self.endpoint = os.getenv("gpt-endpoint")
        self.deployment = "gpt-4o"
        self.subscription_key = os.getenv("gpt-key")
        self.api_version = "2024-12-01-preview"
        
        if not self.endpoint or not self.subscription_key:
            raise ValueError("Please set the gpt-endpoint and gpt-key in the environment variables.")
        
        # LLM 클라이언트 초기화
        self.client = AzureOpenAI(
            api_version=self.api_version,
            azure_endpoint=self.endpoint,
            api_key=self.subscription_key,
        )
        
        # 대화 기록 초기화
        self.conversation_history = []
        
        # 토큰 카운터 초기화
        self.tokenizer = tiktoken.get_encoding("cl100k_base")  # GPT-4o용 토크나이저
        self.token_count = 0
        self.MAX_TOKENS = 400  # 최대 토큰 제한
        
    def _count_tokens(self, text: str) -> int:
        """문자열의 토큰 수 계산"""
        return len(self.tokenizer.encode(text))
    
    def _count_message_tokens(self, messages: List[Dict[str, Any]]) -> int:
        """대화 메시지 목록의 총 토큰 수 계산"""
        total = 0
        for message in messages:
            total += self._count_tokens(message.get("content", ""))
        return total
        
    def enrich_caption(self, analysis_result):
        """캡션 풍부화: 간결한 설명 생성"""
        caption = analysis_result.get("caption", "")
        dense_captions = analysis_result.get("dense_captions", [])
        
        # 상세 캡션 텍스트 포맷팅
        dense_captions_text = "\n".join([f"- {dc}" for dc in dense_captions])
        
        prompt = f"""
이미지 설명:
주요 설명: {caption}
세부 요소들:
{dense_captions_text}

이 정보를 바탕으로 이미지를 시각적으로 생생하게 묘사해주세요.
"""

        response = self.client.chat.completions.create(
            model=self.deployment,
            messages=[
                {"role": "system", "content": "당신은 이미지를 할아버지나 할머니에게 묘사하는 손자, 손녀입니다. 생생한 설명을 제공하고 그때의 감성에 대해 풍부하게 설명합니다."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=2048,
            temperature=1.0,
            top_p=1.0,
        )
        
        # 시스템 메시지 설정 (간결하게 수정)
        system_message = f"""

당신은 이미지에 대해 할머니 할아버지와 같이 어르신들과 대화하는 어시스턴트입니다. 
다음 이미지 정보를 바탕으로 사용자의 질문에 답변하세요. 또한 이미지에 대한 흥미로운 질문을 먼저 사용자에게 던져 대화를 시작하세요:

주요 설명(Caption): 
{caption}
세부 요소들(Dense Captions):
{dense_captions_text}

질문의 주 설명은 caption을 바탕으로 하며, 세부 요소들은 dense captions을 바탕으로 합니다.
이 이미지를 시각적으로 생생하고 디테일하게 묘사해주세요. 할아버지 또는 할머니에게 물어보는 것처럼 그때 당시에 어떤 감정이었는지 또는 어떠한 일이 있었는지에 대해 물어봐야합니다. 그리고 사용자가 늙은분들 위주이다보니 치매 환자라고 가정하고 대화하세요. 혹시나 사용자가 질문에 대한 
대답을 잘못하거나 엉뚱한 방향으로 대답을 하더라도 친절하게 이끌어줘.

아래는 대화 중 발생할 수 있는 문제와 해결 방법이야:

문제 1: 질문을 이해하지 못할 경우
해결 방법 1: 질문 단순화 및 재구성
예시:
원래 질문: “당신 인생에서 자랑스러웠던 순간은 언제였나요?”
변경: “기분이 아주 좋았던 기억이 있나요?”
또는: “학교 졸업하거나 아이를 낳았던 날이 기억나시나요?”

해결 방법 2: 선택지를 제공
예시:
“첫 직장은 사무실이었나요? 가게였나요? 아니면 다른 곳이었나요?”

해결 방법 3: 예시나 맥락을 함께 제공
예시:
“어떤 분들은 부모님과 나눈 대화가 기억에 남는다고 해요. 선생님은 어떠세요?”

문제 2: 완전히 엉뚱한 대답을 할 경우
해결 방법 1: 대답을 수용하면서 주제를 유도
예시:
질문: “어릴 적 친구들은 어떤 사람이었나요?”
대답: “토마토가 좋아.”

대응: “토마토를 좋아하셨군요! 혹시 어릴 때 정원에서 토마토를 키우셨나요?”
해결 방법 2: 자연스럽게 이어가기
대답의 일부분이라도 대화 주제에 연결될 수 있도록 이어 말합니다.

문제 3: 말이 불명확하거나 잘 안 들릴 경우
해결 방법 1: 음성 인식(STT) 결과 신뢰도 활용
정확확도가 낮을 경우 다음과 같이 확인 질문을 합니다.

예시:
“방금 생일 케이크에 대해 말씀하신 것 같아요. 맞으신가요?”
해결 방법 2: 버튼/그림/예·아니오 입력 제공
예시:
“이 음식들 중 어떤 걸 가장 좋아하셨어요?” (이미지 3개 보여주기)
또는: “네/아니오 중에 눌러 주실 수 있나요?”
해결 방법 3: 충분한 시간과 비언어적 신호 인식
대답까지 충분한 기다림
가능하다면 표정/고개 끄덕임/손짓도 인식

문제 4: 아예 대답을 못할 경우
해결 방법 1: 심리적 부담 없이 넘어가기
예시:
“기억이 안 나셔도 괜찮아요. 다른 얘기해볼까요?”
“기억이 나면 언제든 말씀해 주세요.”
시스템 설계 팁
질문이 이해 안 될 때 자동으로 재질문하거나,

유도 질문 → 선택지 제공 → 예/아니오 질문 순으로 난이도 조절

음성 인식 정확도 기준으로 자동 대응 방식 바꾸기

대답의 의도나 감정에 집중하여 수용하는 태도 유지

예시 흐름:

“어릴 적 기억 중 가장 행복했던 순간이 있으신가요?”

→ 이해 못함 → “그럼 어릴 적 자주 놀던 곳이 있었나요?”

→ “토마토”라고 응답 → “정원에서 토마토를 키우셨나요?”

→ 말이 안 들림 → “제가 방금 ‘정원’이라고 들은 것 같은데 맞을까요?”

→ 그래도 대답 못함 → “괜찮아요. 오늘 아침엔 뭐 드셨어요?”


그리고 사용자가 사진에 대한 설명을 원할경우 사진에 대한 설명을 해줘. 그리고 어떤 느낌이 드는지에 대해 물어봐줘."""
        
        # 대화 기록 초기화 및 토큰 수 계산
        self.conversation_history = [{"role": "system", "content": system_message}]
        self.token_count = self._count_tokens(system_message)
        
        description = response.choices[0].message.content
        return description
    
    def generate_initial_question(self):
        """첫 질문 생성 함수"""
        response = self.client.chat.completions.create(
            model=self.deployment,
            messages=self.conversation_history + [
                {"role": "user", "content": "이 옛날 사진에 대해 어르신에게 물어볼 첫 질문을 만들어주세요. 간단하고 기억하기 쉬운 질문이어야 합니다."}
            ],
            max_tokens=512,
            temperature=0.8,
            top_p=1.0,
        )
        
        initial_question = response.choices[0].message.content
        
        # 질문 추가 및 토큰 수 업데이트
        self.conversation_history.append({"role": "assistant", "content": initial_question})
        self.token_count += self._count_tokens(initial_question)
        
        return initial_question
    
    def chat_about_image(self, user_query):
        """사용자 질문에 대한 응답 생성"""
        # 토큰 제한 확인
        user_tokens = self._count_tokens(user_query)
        
        # 사용자 입력 추가
        self.conversation_history.append({"role": "user", "content": user_query})
        self.token_count += user_tokens
        
        # 토큰 제한 초과 확인
        if self.token_count > self.MAX_TOKENS:
            answer = "죄송합니다, 나중에 다시 얘기해요. 지금은 잠시 쉬어야 할 것 같아요. 만약 더 많은 대화를 원한다면 MEMENTO BOX Premium을 사용해보세요."
            self.conversation_history.append({"role": "assistant", "content": answer})
            return answer, True  # True는 대화 종료 신호
        
        # LLM 응답 생성
        response = self.client.chat.completions.create(
            model=self.deployment,
            messages=self.conversation_history,
            max_tokens=1024,
            temperature=0.7,
            top_p=1.0,
        )
        
        # 응답 추출
        answer = response.choices[0].message.content
        
        # 응답 추가 및 토큰 수 업데이트
        self.conversation_history.append({"role": "assistant", "content": answer})
        self.token_count += self._count_tokens(answer)
        
        # 토큰 제한 초과 확인 (응답 후)
        if self.token_count > self.MAX_TOKENS:
            return answer, True  # 대화 종료 신호
        
        return answer, False  # 대화 계속


def analyze_and_describe_image(image_path):
    """이미지 분석 및 설명 통합 함수"""
    # 1. 이미지 분석 객체 생성
    analyzer = ImageAnalysis()
    
    # 2. 이미지 분석 수행
    print(f"이미지 분석 중: {image_path}")
    analysis_result = analyzer.analyze_local_image(
        image_path=image_path,
        features=["caption", "denseCaptions"]
    )
    
    if not analysis_result:
        return "이미지 분석에 실패했습니다.", None
    
    # 3. LLM 설명 생성 객체 생성
    llm_describer = LLMDescription()
    
    # 4. 풍부한 설명 생성
    print("\n풍부한 설명 생성 중...")
    detailed_description = llm_describer.enrich_caption(analysis_result)
    
    # 5. 결과 출력
    print("\n===== 최종 이미지 설명 =====")
    print(detailed_description)
    
    return detailed_description, llm_describer


# 메인 실행부
if __name__ == "__main__":
    # 분석할 이미지 경로 입력 (직접 입력 또는 인자로 받을 수 있음)
    image_path = "pictures\KakaoTalk_20250519_011649615.jpg"
    
    # 이미지 분석 및 설명 생성
    detailed_description, llm_chat = analyze_and_describe_image(image_path)
    
    if llm_chat:
        print("\n===== 이미지에 관한 대화 시작 =====")
        
        # LLM이 먼저 질문 던지기
        initial_question = llm_chat.generate_initial_question()
        print(f"\nAI: {initial_question}")
        
        print("\n대화를 종료하려면 'exit' 또는 '종료'를 입력하세요.")
        
        while True:
            user_query = input("\n답변을 입력하세요: ")
            
            # 수동 종료 조건 확인
            if user_query.lower() in ['exit', '종료', 'quit', 'q']:
                print("대화를 종료합니다.")
                break
            
            # LLM에게 사용자 질문 전달 및 토큰 제한 확인
            answer, should_end = llm_chat.chat_about_image(user_query)
            print(f"\nAI: {answer}")
            
            # 토큰 제한으로 인한 종료 확인
            if should_end:
                print("\n대화 토큰 제한에 도달했습니다. 대화를 종료합니다.")
                break
    else:
        print("이미지 분석에 실패하여 대화를 시작할 수 없습니다.")