/**
 * Created by MatteoSala on 09/07/2020.
 */

import { LightningElement, api } from "lwc";

export default class FieldsList extends LightningElement {
  @api fieldslist;
  @api itemunderid;
  @api draggable;

  handleDragOver(evt) {
    evt.preventDefault();
  }

  handleItemDrag(evt) {
    const event = new CustomEvent("listitemdrag", {
      detail: evt.detail
    });

    this.dispatchEvent(event);
  }

  handleDrop() {
    const event = new CustomEvent("itemdrop");

    this.dispatchEvent(event);
  }

  handleItemDragOver(evt) {
    const event = new CustomEvent("listitemover", {
      detail: evt.detail
    });

    this.dispatchEvent(event);
  }

  handleNewOrder(evt) {
    const event = new CustomEvent("listitemneworder", {
      detail: evt.detail
    });

    this.dispatchEvent(event);
  }

  handleVisibleChanged(evt) {
    const event = new CustomEvent("listitemvisiblechanged", {
      detail: evt.detail
    });

    this.dispatchEvent(event);
  }

  handleDeleteItem(evt) {
    const event = new CustomEvent("listitemdelete", {
      detail: evt.detail
    });

    this.dispatchEvent(event);
  }

  onObjectApiNameSearch(evt) {
    const event = new CustomEvent("fieldobjectnamesearch", {
      detail: evt.target.value
    });

    this.dispatchEvent(event);
  }

  onFieldApiNameSearch(evt) {
    const event = new CustomEvent("fieldapinamesearch", {
      detail: evt.target.value
    });

    this.dispatchEvent(event);
  }
}