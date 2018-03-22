# WebtoonCutter
선택한 폴더에 들어있는 JPG 이미지들을 하나로 모은 다음 일정한 높이로 잘라낸 여러 JPG를 뱉어내는 macOS용 앱입니다.  
[호랑 작가님이 배포하는 프로그램](https://studiohorang.blog.me/120130841009)의 맥용 버전이라고 볼 수도 있습니다.  

## 동작
 - 선택한 폴더에서 JPG 파일들을 추려서 이름 오름차순으로 보여줍니다.
 - 모든 이미지를 세로로 이어붙힌 다음 Width를 기준으로 리사이즈합니다.
 - Height per slice 만큼씩 잘라서 Prefix-일련번호.jpg를 sliced 하위 폴더에 저장합니다.

## 주의
0.2버전으로 아직 여기저기 못이 튀어나와 있습니다.  
모든 동작은 메인 스레드에서 돌아갑니다.  
sliced 폴더의 같은 이름을 가진 파일은 묻지 않고 덮어씁니다.  

### [다운로드](https://mediaetc.s3.amazonaws.com/WebtoonCutter.zip)