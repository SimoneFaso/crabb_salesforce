/**
 * Created by msala on 04/05/2020.
 */

import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';

import LIBS_PATH from '@salesforce/resourceUrl/CrabbLibs';

export default class LcaPatrimonioColumnChart extends LightningElement {
  @api chartSize;
  @api chartTitle;
  @api
  get chartData() {
    return this._data;
  }
  set chartData(value) {
    const shouldRerender = this._data != null;
    this._data = value;
    if (shouldRerender) {
      this.drawChart(value);
    }
  }

  @api legend = [];

  connectedCallback() {
    Promise.all([
      loadScript(this, LIBS_PATH + '/d3.min.js')
    ]).then(() => this.drawChart(this._data));

    this.legend = this.legend.map(item => ({
      background: `background: ${item.color}`,
      desc: item.desc
    }))
  }

  drawChart(data) {
    if (!data) {
      return;
    }
    const container = this.template.querySelector('.Chart');
    d3.select(container).select('*').remove();
    const svg = d3.select(container).append('svg'),
      chartWidth = container.getBoundingClientRect().width,
      width = 280,
      height = 340;

    svg.attr('viewBox', `0 0 ${chartWidth} ${height + 40}`);
    svg.attr('width', '100%');
    svg.attr('height', height + 40);

    const g = svg.append('g').attr('transform', `translate(50, 10)`);
    const yScale = d3.scaleLinear().range([height, 0]);

    const dataSum = Math.max(this.chartSize, d3.sum(data, d => d.ctv));
    yScale.domain([0, dataSum]);

    const yAxis = g.append("g").call(
      d3.axisLeft(yScale).ticks(5).tickFormat(text => this.numberToText(text)).tickSize(-width).tickPadding(10)
    );
    yAxis.selectAll('text').style('fill', '#3E3E3C').style('font-size', '12px');
    yAxis.selectAll('line').style('stroke', '#DDDBDA');
    yAxis.selectAll('.domain').remove();

    const bandwidth = 106;
    let stack = 0;
    const cloned = JSON.parse(JSON.stringify(data));
    cloned.forEach(item => {
      item.stack = stack;
      stack += item.ctv;
    });

    //g.append('text').text('Pratica Ageing').attr('text-anchor', 'middle')
    g.append('text').text(this.chartTitle).attr('text-anchor', 'middle')
      .attr('x', width / 2).attr('y', height + 20)
      .style('font-weight', 'bold');

    g.selectAll(".Col")
      .data(cloned)
      .enter().append("rect")
      .attr("class", ".Col")
      .attr("fill", d => d.color)
      .attr("x", d => width / 2 - bandwidth / 2 )
      .attr("width", bandwidth)
      .attr("y", d => yScale(0))
      .transition().duration(500).ease(d3.easeLinear)
      .attr("y", d => yScale(d.ctv + d.stack))
      .attr("height", d => yScale(d.stack) - yScale(d.ctv + d.stack));

    g.append("rect")
      .attr("fill", 'none')
      .attr("stroke", 'black')
      .attr("stroke-width", 2)
      .attr("x", d => width / 2 - bandwidth / 2 )
      .attr("width", bandwidth)
      .attr("y", d => yScale(this.chartSize))
      .attr("height", d => yScale(0) - yScale(this.chartSize));
  }

  numberToText(value) {
    const sizes = ['', 'k', 'mln', 'mld'];
    if (value == null) {
      return '-';
    }
    if (value === 0) {
      return '0';
    }

    const i = Math.floor(Math.log(Math.abs(value)) / Math.log(1000));
    if (i < 1) {
      return new Intl.NumberFormat('it-IT', { maximumFractionDigits: 0 }).format(value);
    }
    const rounded = value / Math.pow(1000, i);
    return new Intl.NumberFormat('it-IT', { maximumFractionDigits: 1, minimumFractionDigits: 0}).format(rounded) + ' ' + sizes[i];
  };
}