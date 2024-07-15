import React, { useEffect, useState } from 'react'
import { Card, Form, Grid, Input, Statistic } from 'semantic-ui-react'

import { useSubstrateState } from './substrate-lib'
import { TxButton } from './substrate-lib/components'

function Main(props) {
  const { api } = useSubstrateState()

  // The transaction submission status
  const [status, setStatus] = useState('')

  // The currently stored value
  const [currentValue, setCurrentValue] = useState(0)
  const [formValue, setFormValue] = useState(0)

  useEffect(() => {
    let unsubscribe
    ;(async () => {
      try {
        debugger // eslint-disable-line
        // const something = await api.query.riskRatings.something()
        const riskRatings = await api.query.riskRatings.latestRiskRatings(1, 1)

        debugger // eslint-disable-line

        if (riskRatings.isNone) {
          debugger // eslint-disable-line
          setCurrentValue('<None>')
        } else {
          debugger // eslint-disable-line
          setCurrentValue(riskRatings.unwrap().toNumber())
        }

        // console.log('something', something) // eslint-disable-line
        // console.log('riskRatings', riskRatings) // eslint-disable-line

        // setCurrentValue(riskRatings.unwrap().toNumber())
      } catch (error) {
        debugger // eslint-disable-line
        console.error('Error:', error)
      }
    })()

    // .something(newValue => {
    //   debugger // eslint-disable-line
    //   // The storage value is an Option<u32>
    //   // So we have to check whether it is None first
    //   // There is also unwrapOr
    //   if (newValue.isNone) {
    //     debugger // eslint-disable-line
    //     setCurrentValue('<None>')
    //   } else {
    //     debugger // eslint-disable-line
    //     setCurrentValue(newValue.unwrap().toNumber())
    //   }
    // })
    // .then(unsub => {
    //   unsubscribe = unsub
    // })
    // .catch(console.error)

    return () => unsubscribe && unsubscribe()
  }, [api.query.riskRatings])

  return (
    <Grid.Column width={8}>
      <h1>Risk Ratings</h1>
      <Card centered>
        <Card.Content textAlign="center">
          <Statistic label="Current Value" value={currentValue} />
        </Card.Content>
      </Card>
      <Form>
        <Form.Field>
          <Input
            label="New Value"
            state="newValue"
            type="number"
            onChange={(_, { value }) => setFormValue(value)}
          />
        </Form.Field>
        <Form.Field style={{ textAlign: 'center' }}>
          <TxButton
            label="Store Something"
            type="SIGNED-TX"
            setStatus={setStatus}
            attrs={{
              palletRpc: 'riskRatings',
              callable: 'doSomething',
              inputParams: [formValue],
              paramFields: [true],
            }}
          />
        </Form.Field>
        <div style={{ overflowWrap: 'break-word' }}>{status}</div>
      </Form>
    </Grid.Column>
  )
}

export default function RiskRatings(props) {
  const { api } = useSubstrateState()
  return api.query.riskRatings && api.query.riskRatings.latestRiskRatings ? (
    <Main {...props} />
  ) : null
}
