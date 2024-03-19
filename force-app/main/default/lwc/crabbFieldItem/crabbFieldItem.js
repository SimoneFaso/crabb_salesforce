/**
 * Created by MatteoSala on 09/07/2020.
 */

import { LightningElement, api } from "lwc";

export default class FieldItem extends LightningElement
{
  @api field;
  @api itemunderid;
  @api draggable;

  get objectApiName() {
    return this.field.CRABB_DEV__Object__c.replace("CSV||", "");
  }

  get order() {
    const strNumber = this.field.Name.replace("CSVNEW", "");

    // eslint-disable-next-line radix
    return parseInt(strNumber);
  }

  get isUnder() {
    if (!this.itemunderid) return false;
    return this.itemunderid === this.field.Id;
  }

  itemDragStart() {
    const event = new CustomEvent("itemdrag", {
      detail: this.field.Id
    });

    this.dispatchEvent(event);
  }

  handleDragOver() {
    const event = new CustomEvent("itemdragover", {
      detail: this.field.Id
    });

    this.dispatchEvent(event);
  }

  handleDelete() {
    const event = new CustomEvent("deleteitem", {
      detail: {
        fieldId: this.field.Id
      }
    });

    this.dispatchEvent(event);
  }

  onIsVisibleChanged(evt) {
    const event = new CustomEvent("visiblechanged", {
      detail: {
        fieldId: this.field.Id,
        isVisible: evt.target.checked
      }
    });

    this.dispatchEvent(event);
  }

  orderEntered(evt) {
    // only when enter is pressed
    const newName = this.createNameFromNumber(evt.target.value);

    // notifying that this field has new order (the field name is different for it now)
    const event = new CustomEvent("neworder", {
      detail: {
        fieldId: this.field.Id,
        newName
      }
    });

    this.dispatchEvent(event);
  }

  createNameFromNumber(number) {
    const staticPart = ("000000" + number).slice(-7);

    return `CSVNEW${staticPart}`;
  }
}