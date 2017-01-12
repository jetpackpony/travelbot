import React from 'react';

export default function(props) {
  return (
    <div className={"message" + (props.ownMessage ? " message-mine" : "")}>
      {props.message.label}
    </div>
  );
}
