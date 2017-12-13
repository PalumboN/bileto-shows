class Pedido {
  constructor() {
    this.empanadas = [new Empanada("Humita")]
    this.precioXUnidad = 20
  }

  cargarGustos() {
  }

  cantidadTotal() {
    return _(this.empanadas).map("cantidad").sum()
  }

  precio() {
    return this.precioXUnidad * this.cantidadTotal()
  }

  cumpleCantMinima() {
    return this.cantidadTotal() >= 4
  }
}

class Empanada {
  constructor(gusto) {
    this.gusto = gusto
    this.cantidad = 0
  }

  sumar() { this.cantidad++ }

  restar() { this.cantidad-- }

  fuePedida() { return this.cantidad > 0 }
}
