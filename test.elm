module Main exposing (budgetView)


budgetView : GenerateBudgetChartData -> BudgetInput -> Html msg
budgetView generateBudgetChartData budgetInput =
    div []
        [ section [ class "section" ]
            [ div [ class "container" ]
                [ div [ class "field has-addons" ]
                    [ div [ class "control" ]
                        [ input [ id "spendInput", class "input", type_ "number", placeholder "予算金額" ] [] ]
                    , div [ class "control" ]
                        [ button
                            [ class
                                ((\busy ->
                                    if busy == True then
                                        "button is-info is-loading"

                                    else
                                        "button is-info"
                                 )
                                    budgetInput.busy
                                )
                            ]
                            [ text "登録" ]
                        ]
                    ]
                , canvas [ id "myChart" ] []
                ]
            ]
        ]


port generateBudgetChart : GenerateBudgetChartData -> Cmd msg

app.ports.generateBudgetChart.subscribe(
  async (data: { budget: number; spendSum: number }) => {
    console.log('generateBudgetChart')
    await new Promise(resolve => setTimeout(resolve, 100))
    const el = document.getElementById('myChart') as HTMLCanvasElement
    const ctx = el.getContext('2d')
    if (ctx == null) {
      return
    }

    new Chart(ctx, {
      type: 'bar',

      data: {
        labels: ['予算', '支出'],
        datasets: [
          {
            label: '予算',
            backgroundColor: ['blue', 'red'],
            data: [data.budget, data.spendSum],
          },
        ],
      },

      options: {
        scales: {
          yAxes: [
            {
              ticks: {
                beginAtZero: true,
              },
            },
          ],
        },
      },
    })
  }
)