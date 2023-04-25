# 과제 Q/A

## GET /api/v1/movies

### Filter

- /api/v1/movies?productDirector?genre=romance&update=DESC
  - 해당 쿼리로 정렬되는 영화는 장르가 코메디이자 Update가 최신에 된 순서로 정렬될 것.
    - updatedAt이 아닌 update 항목을 따로 생성해야함 그렇지 않은 경우 컬럼의 수정이 생겨도 상위 항목으로 올라감
- /api/v1/movies?genre=comedy&grade=DESC
  - 코미디 장르의 평점이 높은 순서로 정렬

<br>

- 성공정으로 filtering 한 경우

  - status code: `200(OK)`
  - 해당 필터링으로 정렬된 리소스의 결과값을 return

<br>

- Filter를 포함한 Request를 보내었지만 해당 resouce의 내용이 없다면
  - status code: `404(NOT Found)`
  - 해당 필터를 적용한 리소스는 존재하지 않는 리소스라는 결과값을 return 값으로 제공함

## GET /api/v1/movies/{movie_id}

- 성공인 경우

  - status code: `200(OK)`
  - 해당 영화 id 즉 `{movie_id}` 1인 경우 1번의 ID를 갖고있는 영화의 리소스를 reutrn

<br>

- Entity가 존재하지 않는 경우
  - status code: `404(Not Found)`
  - 해당 `movie_id`를 갖은 영화는 존재하지 않다는 결과값을 return

## POST/api/v1/movies

- INPUT

```javascript
{
    method: 'POST',
    url: 'http://localhost:8000/api/v1/movies',
    body: {
        title: '화양연화',
        originalTitle: "花樣年華",
        release: 2000,
        ...
    },
    headers: { 'Content-Type': 'application/json' }
}
```

- 성공인 경우

  - status code: `201(Created)`
  - 민감한 정보가 영화에 있을지는 잘 모르겠지만 민간함 정보와, createdAt, updatedAt등의 데이터를 제외한 생성된 Entity 리소스 제공

<br>

- Entity가 기존에 있는 데이터와 충동을 일으킨 경우
  - status code: `409(Conflict)`
  - 해당 데이터는 기존 데이터와의 충돌이 발생했다는 결과값을 return <br>
    내부적으로는 Trasaction을 이용하여 create 하지 못한 결과값에 대해서는 rollback을 진행 시켜도 좋을것 같음

<br>

- Entity를 생성하는 과정에서 내부 문제로 생성이 원할하게 이루어지지 않은 경우
  - status code: `500(Internal Server Error)`
  - 클라이언트가 오류의 해결 밥법을 이해하는 데 도움이 되는 정보를 추가하여 return

## PUT /api/v1/movies/{movie_id}

- 성공인 경우

  - status code: `200(OK)`
  - 업데이트 된 리소스에 대한 정보를 반환 _ 민감한 정보는 제외 _

  <br>

- Entity의 내용이 받아들일 수 없는 경우
  - status code: `422(Unprocessable Entity)`
  - 예를 들어 영화의 Title이 비어있는 경우 Title은 빈칸일수 없다는 등의 클라이언트가 이해할 수 있는 결과값을 리턴해줌

## DELETE /api/v1/movies/{movie_id}

- 성공인 경우

  - status code: `204(No Content)`
  - 서버가 요청을 성공적으로 처리하지만 콘텐츠를 반환하지는 않음

<br>

- 삭제하려는 Entity가 존재하지 않는 경우
  - status code: `404(Not Found)`
  - 해당 데이터는 존재하지 않는 데이터라는 것을 클라이언트에게 알림
